import setuptools

setuptools.setup(
	name = "fastbooru",
	version= "0.1.0",
	description = "Because all other cli downloaders suck...",
	long_description = open("README.md", "r").read(),
	long_description_content_type = "text/markdown",
	author = "Cloud11665",
	author_email = 'Cloud11665@protonmail.com',
	url = "https://github.com/cloud11665/fastbooru",
	packages = setuptools.find_packages(),
	install_requires = setuptools.find_packages(),
	license= "gnu GPL-3.0",
	include_package_data = True,
	package_data = {"fastbooru": ["*.hy"]},
	entry_points = {
		"console_scripts": [
			"fastbooru = fastbooru:main"
		]
	},
	classifiers=[
		"Programming Language :: Python :: 3.7",
		"Programming Language :: Python :: 3.8",
		"Programming Language :: Python :: 3.9",
		"Operating System :: OS Independent"
	],
	python_requires = ">=3.7"
)