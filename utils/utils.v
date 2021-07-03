module utils

import os
import term
import cli { Command }

pub const (
	nvenv_home     = os.home_dir() + '/.local/share/nvenv'
	nvenv_cache    = os.cache_dir() + '/nvenv'
	nvenv_current  = nvenv_home + '/current'
	nvenv_versions = nvenv_home + '/versions'
	nvim_current   = os.home_dir() + '/.local/bin/nvim'
)

const (
	nvim_releases = 'https://github.com/neovim/neovim/releases/download'
)

/*
Utility functions:
		- log_msg
		- warn_msg
		- error_msg
		- setup_exists
		- check_current
		- check_version
		- check_command
		- print_versions
		- version_path
		- get_files
		- get_subdirs
		- remove_symlink
		- download_path
		- download_url
*/

// Send a log message with coloring
pub fn log_msg(message string) {
	println('[${term.bold(term.green('LOG'))}] $message')
}

// Send a warning message with coloring
pub fn warn_msg(message string) {
	eprintln('[${term.bold(term.yellow('WARN'))}] $message')
}

// Send an error with coloring and its exit code
pub fn error_msg(message string, exit_code int) {
	eprintln('[${term.bold(term.red('ERR'))}] $message')
	exit(exit_code)
}

// Check if the nvenv directories exists
pub fn setup_exists(_ Command) ? {
	if !os.exists(utils.nvenv_home) {
		error_msg('You must need to setup nvenv first, run `nvenv setup`.', 1)
	}
}

// Check the current used version
pub fn check_current() string {
	if !os.exists(utils.nvenv_current) {
		return ''
	}

	full_path := os.execute('readlink $utils.nvenv_current').output
	if full_path == '' {
		return ''
	}

	return os.base(full_path).trim('\n')
}

// Check if the given version is empty
pub fn check_version(version string, info string) {
	if version == '' {
		eprintln('[ERR] Please specific the version to $info')
		exit(1)
	}
}

// Check if the given program exists in the system's PATH
pub fn check_command(command string) {
	if !os.exists_in_system_path(command) {
		warn_msg("Need '$command' (command not found)")
	}
}

// Pretty print the local versions
pub fn print_versions(versions []string, remote bool) {
	current_version := check_current()
	mut nvim_versions := versions.clone()

	// by default the sort function sorts from 0-9 to a-z so we need to reverse
	// the order. In that way, stable and nightly will appear first.
	nvim_versions.sort()
	for version in nvim_versions.reverse() {
		// If listing remote versions, current version exists and version is equal to it
		if remote && (current_version != '' && version == current_version) {
			println('$version\t(installed, used)')
			// If not listing remote versions, current version exists and version is equal to it
		} else if !remote && (current_version != '' && version == current_version) {
			println('$version\t(used)')
		} else if version != '' {
			// If listing remote versions, and version is installed
			if remote && os.exists(version_path(version)) {
				println('$version\t(installed)')
				// If listing remote or if not listing remote and version is installed
			} else if remote || (os.exists(version_path(version)) && !remote) {
				println('$version')
			}
		}
	}
}

// Returns the version path
pub fn version_path(version string) string {
	return '$utils.nvenv_versions/$version'
}

// Get files in given folder
pub fn get_files(dir string) []string {
	mut files := []string{}

	// Return empty array if directory is empty
	if os.is_dir_empty(dir) {
		return files
	}

	for file in os.execute('find $utils.nvenv_cache -type f').output.split('\n') {
		if file != '' {
			files << file
		}
	}

	return files
}

// Get subdirectories in given folder
pub fn get_subdirs(parent_dir string) []string {
	mut subdirs := []string{}

	// Return empty Array if parent_dir is empty
	if os.is_dir_empty(parent_dir) {
		return subdirs
	}

	for dir in os.execute('ls -d $parent_dir/*').output.split('\n') {
		if os.base(dir) != '.' {
			subdirs << os.base(dir)
		}
	}

	return subdirs
}

// Remove a symlink
pub fn remove_symlink(link string) bool {
	if os.system('unlink $link') == 0 {
		return true
	} else {
		return false
	}
}

// format url to download
// https://github.com/neovim/neovim/releases/download/<VERSION>/nvim-<OS>.tar.gz
pub fn download_url(version string) string {
	mut dl_version := version
	if dl_version != 'nightly' && dl_version != 'stable' {
		dl_version = 'v' + version
	}

	$if linux && x64 {
		dl_version = utils.nvim_releases + '/$dl_version/nvim-linux64.tar.gz'
	} $else $if macos {
		dl_version = utils.nvim_releases + '/$dl_version/nvim-macos.tar.gz'
	}

	return dl_version
}

// Returns the local path for downloaded source files and
// the downloaded file name
pub fn download_path(version string) (string, string) {
	filename := '${version}.tar.gz'

	return '$utils.nvenv_cache/$filename', filename
}
