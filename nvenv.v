import os
import utils
import cli { Command, Flag }

fn main() {
	mut cmd := Command{
		name: 'nvenv'
		description: 'Neovim Version Manager'
		version: '1.0.0'
		disable_flags: true
	}

	mut setup_cmd := Command{
		name: 'setup'
		description: 'Setup Nvenv, required at first usage.'
		execute: setup
	}

	mut list_cmd := Command{
		name: 'ls'
		description: 'List your installed Neovim versions.'
		pre_execute: utils.setup_exists
		execute: list
	}

	mut list_remote_cmd := Command{
		name: 'list-remote'
		description: 'List the available Neovim versions.'
		pre_execute: list_remote_pre
		execute: list_remote
	}
	list_remote_cmd.add_flag(Flag{
		flag: .int
		name: 'versions'
		abbrev: 'v'
		default_value: ['6']
		description: 'Remote versions to show.'
	})

	mut install_cmd := Command{
		name: 'install'
		description: 'Install a specific version of Neovim.'
		usage: '<version>'
		required_args: 1
		pre_execute: utils.setup_exists
		execute: install
	}

	mut uninstall_cmd := Command{
		name: 'uninstall'
		description: 'Uninstall a specific version of Neovim.'
		usage: '<version>'
		required_args: 1
		pre_execute: utils.setup_exists
		execute: uninstall
	}
	uninstall_cmd.add_flag(Flag{
		flag: .bool
		name: 'force'
		abbrev: 'f'
		default_value: ['false']
		description: 'Force uninstallation.'
	})
	uninstall_cmd.add_flag(Flag{
		flag: .bool
		name: 'clean'
		abbrev: 'c'
		default_value: ['false']
		description: 'Uninstall and clean the cache files of the version.'
	})

	mut update_cmd := Command{
		name: 'update'
		description: 'Update a specific version of Neovim.'
		usage: '<version>'
		required_args: 1
		pre_execute: utils.setup_exists
		execute: update
	}

	mut use_cmd := Command{
		name: 'use'
		description: 'Use a specific version of Neovim.'
		usage: '<version>'
		required_args: 1
		pre_execute: utils.setup_exists
		execute: use
	}

	mut clean_cmd := Command{
		name: 'clean'
		description: "Clean Nvenv's cache files"
		pre_execute: utils.setup_exists
		execute: clean
	}

	cmd.add_commands([setup_cmd, list_cmd, list_remote_cmd, install_cmd, uninstall_cmd, update_cmd,
		use_cmd, clean_cmd])
	cmd.setup()
	cmd.parse(os.args)
}

fn setup(cmd Command) ? {
	dependencies := ['curl', 'tar', 'jq']

	if !os.exists(utils.nvenv_home) {
		// Create required directories
		// /home/user/.cache/nvenv => cache files for nvenv
		// /home/user/.local/bin => where nvim will be symlinked
		// /home/user/.local/share/nvenv/versions => core files for nvenv
		os.mkdir_all(utils.nvenv_cache) ?
		os.mkdir_all('$os.home_dir()/.local/bin') ?
		os.mkdir_all(utils.nvenv_versions) ?
		// Check for missing dependencies
		for dependency in dependencies {
			utils.check_command(dependency)
		}
	} else {
		utils.error_msg('Setup is already done.', 1)
	}
}

fn list_remote_pre(_ Command) ? {
	utils.log_msg('Fetching remote versions ...\n')
}

// List remote versions of Neovim by pulling them from the repository.
fn list_remote(cmd Command) ? {
	versions_to_show := cmd.flags.get_int('versions') ?
	releases := 'https://api.github.com/repos/neovim/neovim/releases'
	jq_cmd := 'jq \'[.[] | select(.tag_name!="v0.4.4") | .tag_name] | .[:$versions_to_show] | .[]\''
	
	remote_versions := os.execute('curl -s $releases | $jq_cmd').output
	if remote_versions.len == 0 {
		utils.error_msg('Failed to get Neovim releases.', 3)
	}

	/*
	Trim leading `v` and leading `"`
	*/
	remote_versions_list := remote_versions.replace('v', '').replace('"', '').split('\n')

	utils.print_versions(remote_versions_list, true)
}

fn list(cmd Command) ? {
	versions := utils.nvenv_versions
	mut installed_versions := utils.get_subdirs(versions)

	if os.is_dir_empty(versions) {
		utils.error_msg("You don't have any version installed.", 2)
	}

	installed_versions.sort_by_len()
	utils.print_versions(installed_versions.reverse(), false)
}

fn install(cmd Command) ? {
	version := cmd.args[0]
	utils.check_version(version, 'install')

	if os.exists(utils.version_path(version)) {
		utils.error_msg('Version $version is already installed. If you want to update it, run `nvenv update $version`.',
			1)
	}

	dl_path, filename := utils.download_path(version)
	if !os.exists(dl_path) {
		dl_url := utils.download_url(version)
		utils.log_msg('Downloading version $version ...')

		if os.system('curl --progress-bar -Lo $dl_path $dl_url') != 0 {
			utils.error_msg('Failed to download version $version ($dl_url)', 2)
		}
	} else {
		utils.log_msg('Using cached files for version $version ...')
	}

	mut tar_name := 'nvim-'
	$if linux && x64 {
		tar_name += 'linux64'
	} $else $if macos {
		tar_name += 'osx64'
	}

	os.rmdir('$utils.nvenv_versions/$tar_name') or { }

	tar_path := '$utils.nvenv_cache/$filename'
	utils.log_msg('Installing version $version ...')
	if os.system('cd $utils.nvenv_cache && tar -xf $tar_path && mv $tar_name $utils.nvenv_versions/$version') != 0 {
		utils.error_msg('Failed to install Nvim.', 3)
	}

	// If there is no current used version then use the new downloaded version as current
	if !os.exists(utils.nvenv_current) {
		use(cmd) ?
		utils.log_msg('Version $version successfully installed.\n      You may need to add $os.home_dir()/.local/bin to your \$PATH.')
	} else {
		utils.log_msg('Version $version successfully installed.\n      You can now use it by doing `nvenv use $version`.')
	}
}

fn uninstall(cmd Command) ? {
	version := cmd.args[0]
	force := cmd.flags.get_bool('force') ?
	clean := cmd.flags.get_bool('clean') ?
	current_version := utils.check_current()
	utils.check_version(version, 'uninstall')

	if !os.exists(utils.version_path(version)) {
		utils.error_msg('Version $version is not installed.', 2)
	}

	if !force && version == current_version {
		utils.error_msg("Version $version cannot be uninstalled because it\'s in use, maybe you want to use `--force`?",
			1)
	}

	utils.log_msg('Uninstalling version $version ...')

	os.rmdir_all(utils.version_path(version)) or {}
	if !force {
		utils.log_msg('Version $version successfully uninstalled.')
	} else {
		if version == current_version {
			// Remove symlinks
			utils.remove_symlink(utils.nvenv_current)
			utils.remove_symlink(utils.nvim_current)

			utils.log_msg('Version $version was in use and was forcibly uninstalled, you must set a new version with `nvenv use <version>`.')
		} else {
			utils.log_msg('Version $version was forcibly uninstalled.')
		}
	}

	if clean {
		cache_file, _ := utils.download_path(version)
		os.rm(cache_file) or {
			utils.error_msg('Cache files for version $version were not found.', 2)
		}

		utils.log_msg('Cache files for version $version were successfully cleaned.')
	}
}

fn update(cmd Command) ? {
	version := cmd.args[0]
	utils.check_version(version, 'update')

	if !os.exists(utils.version_path(version)) {
		utils.error_msg('Version $version is not installed, run `nvenv install $version`.',
			2)
	}

	// /home/user/.local/share/nvenv/versions/version
	target_version := utils.version_path(version)
	// /home/user/.cache/nvenv/version.tar.gz, version.tar.gz
	dl_path, filename := utils.download_path(version)

	// Delete the old cache file
	dl_url := utils.download_url(version)
	utils.log_msg('Downloading version $version update ...')

	if os.system('curl --progress-bar -Lo $dl_path $dl_url') != 0 {
		utils.error_msg('Failed to download version $version update ($dl_url)', 2)
	}

	mut tar_name := 'nvim-'
	$if linux && x64 {
		tar_name += 'linux64'
	} $else $if macos {
		tar_name += 'osx64'
	}

	os.rmdir('$utils.nvenv_versions/$tar_name') or { }

	tar_path := '$utils.nvenv_cache/$filename'
	utils.log_msg('Updating version $version ...')
	// Extract the tarball, move all its content to the existing version directory and then delete the new version dir
	if os.system('cd $utils.nvenv_cache && tar -xf $tar_path && cp -arf $tar_name/* $target_version && rm -r $tar_name') != 0 {
		utils.error_msg('Failed to update Nvim.', 3)
	}

	utils.log_msg('Version $version successfully updated.')
}

fn use(cmd Command) ? {
	version := cmd.args[0]
	current_version := utils.check_current()
	utils.check_version(version, 'use')

	if !os.exists(utils.version_path(version)) {
		utils.error_msg('Version $version is not installed, run `nvenv install $version`.',
			2)
	}

	if version == current_version {
		utils.error_msg('Version $version is already in use', 1)
	}

	target := utils.nvenv_current
	nvim_current_version := utils.nvim_current

	if os.is_link(target) && !utils.remove_symlink(target) {
		utils.error_msg('Failed to use version $version, cannot remove previous symlink ($target)',
			1)
	}

	// Create two symlinks,
	// nvenv_home/current
	// ~/.local/bin/nvim
	os.symlink(utils.version_path(version), target) or {
		utils.error_msg('Failed to use version $version, cannot create symlink ($target)',
			1)
	}

	if !os.is_link(nvim_current_version) {
		os.symlink('$target/bin/nvim', nvim_current_version) or {
			utils.error_msg('Failed to use version $version, cannot create symlink ($nvim_current_version)',
				1)
		}
	}

	utils.log_msg('Using version $version')
}

fn clean(cmd Command) ? {
	if os.is_dir_empty(utils.nvenv_cache) {
		utils.error_msg("You don't have any version installed.", 2)
	}

	utils.log_msg('Cleaning cache files ...')

	for cache_file in utils.get_files(utils.nvenv_cache) {
		os.rm(cache_file) or { }
	}

	utils.log_msg('Cleaned all cache files successfully.')
}
