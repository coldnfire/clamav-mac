# clamav-mac

!!! THIS REPOSITORY STAY IN PROGRESS !!!

Clamav4Mac
The Non-Graphical ClamAV Antivirus Solution for Mac OS X

I wrote this as a free alternative to the excellent ClamXav. MacClam sets up real-time directory monitoring and schedules periodic scans. It uses ClamAV as an AntiVirus engine and fswatch to actively monitor directories for new or changed files, which are then sent to clamd for scanning.

Prerequisites
All prerequies will be automatically installed. I have tested MacClam on High Sierra & Mojave , but it may also work in other versions of OS X.

Installation
Installation is very simple. In a shell, type

git clone https://github.com/coldnfire/clamav-mac.git
chmod 700 install.sh
./install.sh

This will bootstrap Clamav4Mac by building the lastest versions of ClamAV and fswatch from brew. It will schedule a full file system scan once a week and update signatures once a day. It also sets up live monitoring for the $HOME and /Applications directories. Each of these things can be configured by modifying script variables.

By default, the installation directory is ~/clamav-mac. This directory contains all the source, binaries, log files, and quarantine folder. The only artifact of the installation outside this directory is the crontab. MacClam can be totally uninstalled by running ./MacClam.sh uninstall.


Customization
Scheduled scans, monitoring and installation location can be configured by editing configuration variables at the beginning of the script configuration.sh.

Virus Scans
MacClam performs three types of scans:

Active monitoring: Clamav4Mac will monitor any directories you specify for activity. When a file is changed or created, it will be scanned immediately. By default, the $HOME and Applications directories are monitored.
Scheduled scanning: MacClam will perform recursive scans of directories at scheduled times. By default, the entire hard drive is scanned once a week.
In all cases, when a virus is found, it is moved to the quarantine folder and an email is send to the administrator.
