# Overview
cmbootstrap provides zero-code, masterless, metadata-based bootstrapping and configuration management of virtual machine or container instances on AWS, Google Cloud Platform, VMware, VirtualBox and Docker.

cmbootstrap currently supports Ansible based configuration management but support for Puppet and other configuration management tools is planned in the near future.  Retrieval of configuration management files from both Git and Subversion repositories are supported with support for Amazon S3 and Google Cloud Storage (GCS) storage buckets to be added soon.

To define and launch a new server instance using cmbootstrap and Ansible configuration management you only need to perform the following steps:

1. Make your configuration files (Ansible playbooks) available in an appropriate repository such as GitHub, using <code>main.yml</code> as your playbook entry point.
2. Define metadata for your virtual machine or container that maps to these configuration files.
3. Launch cmbootstrap on the virtual machine or container.

When cmbootstrap runs it will automatically:

1. Install [Ansible](http://ansible.com/).
2. Retrieve the appropriate configuration management files based on the metadata that you have defined.
3. Execute the retrieved configuration using Ansible local (masterless) mode.
4. Log the results to a standardized location.

This means:

1. No need to manually install and configure Ansible on your server instances.
2. No need to write shell scripts to automate the Ansible installation, playbook retrieval or playbook execution steps.
3. No need to maintain Ansible "master" or "controller" infrastructure - instead a masterless or "pull" model is used, whereby each instance will provision itself directly from your version control repository.

cmbootstrap will automatically detect and then use the appropriate techniques for metadata retrieval on the following platforms:

1. VirtualBox
2. VMware
3. Docker
4. Google Compute Engine
5. AWS EC2

This means that your configuration management bootstrapping process will be completely portable across various virtualization and container platforms.  For example, you can build and test a configuration using a local VirtualBox virtual machine or Docker container, and then deploy it into EC2 with no further work.

Only three metadata values are required to define what configuration should be used to bootstrap an instance, making it possible to share instance configurations across your team in a very concise form.

cmbootstrap was originally created by [Priocept](http://priocept.com/) to simplify and standardize building of server environments across a wide range of local development, centralised development, test and production environments.  It is written entirely in Bash, for maximum portability across all Unix flavours.  CentOS/RedHat and Debian/Ubuntu Linux distributions are currently supported with Windows support via cygwin to be supported in the near future.

## Introduction to Automated Configuration Management

Ansible, and other similar tools such as Puppet and Chef, automate the process of defining and building server environments.  They achieve this by defining high level languages that can be used to describe the state that a server environment should be in.

For example, instead of manually creating a directory, downloading some software, and installing the software into that directory, configuration management steps can be defined in code so that these tasks are automated and repeatable.  cmbootstrap aims to streamline this process and reduce the learning curve associated with implementing configuration management.

## Configuration Management Bootstrapping

Although Ansible and similar tools provide for automation of server environment configuration, considerable effort is still required to set up Ansible itself, and to implement a method for storing the configuration management files and deploying them to a given Ansible-enabled server.

cmbootstrap automates the process further to provide simplified creation and start-up of server configurations that have been defined using a combination of cmbootstrap metadata and Ansible configuration management files.  No manual installation of Ansible is required and configuration management files do not need to be manually retrieved and deployed to the server.  No centralized Ansible infrastructure is required.  This reduces the learning curve and allows the use of automated configuration management with limited to no knowledge of Ansible or the other underlying technologies.

## Metadata Based Start-Up

cmbootstrap uses metadata to define what configuration should be applied to a new environment.  The metadata consists of simple name/value pairs, and is defined in different ways for different types of virtualization or containerization platforms.  VMware, VirtualBox, Docker, AWS EC2 and Google Compute Engine are currently supported.

For VMware, a cmbootstrap metadata definition is stored within the <code>.vmx</code> file and looks like the following:

<pre>
guestinfo.cm-organization = "MyCompany"
guestinfo.cm-project = "ECommerce_Platform"
guestinfo.cm-type = "Web_Server"
guestinfo.cm-vcs-username = "********"
guestinfo.cm-vcs-password = ""********""
</pre>

In this particular example, the cmbootstrap metadata is configured to start the VM so that it becomes a web server environment, for the "ECommerce_Platform" project for "MyCompany".  This environment can be created simply by editing the above metadata on a virtual machine that supports cmbootstrap, and then starting the VM.  The VM will then auto-configure itself to the desired state.

The VCS (Version Control System) username and password are provided so that cmbootstrap can automatically retrieve the required configuration management files from the version control repository.

## Company, Project and Type Metadata - Mapping to Version Control

cmbootstrap determines where to retrieve its configuration management files, based on the <code>cm-organization</code>, <code>cm-project</code> and <code>cm-type</code> metadata shown in the above example.  These three parameters are then mapped to a given version control system path, as follows:

`https://baseurl/cm-company/cm-project/cm-type/`

for example:

`https://github.com/priocept/<cm-company>/<cm-project>/<cm-type>/`

For the above example metadata, the cmbootstrap framework will look for configuration management files at the following location:

`https://github.com/priocept/MyCompany/ECommerce\_Platform/Web_Server/`

If the necessary files exist at this location, they will be executed and the virtual machine will be configured to the required state.  If the expected files do not exist, the cmbootstrap process will fail.

cmbootstrap currently supports retrieval of configuration management files from either Git or Subversion repositories.  Support for retrieval from Amazon S3 and GCS is planned in the near future.

## Supported Virtual Machine Formats

Different virtualization and containerization technologies may be used within an organization on different projects, and even within different stages of a single project, with initial development and final production environments frequently being on different platforms.

For this reason, cmbootstrap supports multiple platforms, and will automatically detect the current platform and then use the appropriate method to retrieve the metadata.  This means that a single set of cmbootstrap metadata plus a single set of configuration management files can be used to build a given environment on many different types of platform.

The following platforms are currently supported.

### VMware

Configuration management metadata can be defined for VMware via the VM's <code>.vmx</code> file.  The metadata is defined as sub-values of <code>guestinfo</code>, for example:

<pre>
guestinfo.cm-organization = "MyCompany"
</pre>

Example <code>.vmx</code> file entries can be found here:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/metadata/VMWare/>

### VirtualBox

Configuration management metadata can be defined for VirtualBox via the VM's <code>.vbox</code> file.  Since this file is XML based, it is harder to edit manually compared to a VMware <code>.vmx</code> file.  As an alternative you can use the <code>vboxsetmetadata</code> utility shell script which will read metadata from a <code>vboxcm.txt</code> file and then automatically set the VirtualBox metadata using the VirtualBox <code>vboxmanage</code> command.  <code>vboxcom.txt</code> uses a <code>name:value</code> format, one line for each metadata entry, for example:

<pre>
cm-organization:MyCompany
</pre>

An example <code>vboxcm.txt</code> file and supporting scripts can be found here:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/metadata/VirtualBox/>

### Docker

Configuration management metadata can be defined for Docker via environment variable definitions in the container's Dockerfile, for example:

<pre>
ENV CM_ORGANIZATION=MyCompany
</pre>

Note that the metadata names are changed from lowercase to uppercase, and hyphens changed to underscores, for environment variable naming compatibility.

A standard cmbootstrap compatible template Dockerfile is available for download at this location:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/launch/Docker/Dockerfile>

### Amazon EC2 (user data based)

Unlike VMware, VirtualBox and Google Compute Engine, Amazon EC2 virtual machines do not allow for multiple arbitrary metadata fields.  Instead they provide only a single "user data" field as described in the AWS EC2 documentation:

<http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html>

This field therefore has to be used both to launch the cmbootstrap process, and to define the cmbootstrap metadata, in a <code>name:value</code> format as for VirtualBox.

The userdata field becomes a combination of a set of <code>name:value</code> metadata entries, plus some simple bootstrapping code to download and execute cmbootstrap itself.  cmbootstrap will automatically extra <code>name:value</code> format metadata values from the user data field.

A standard cmbootstrap compatible template user data file is available for download at this location:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/launch/AWS/user-data-cmbootstrap.sh>

### Amazon EC2 (tag based)

Alternatively, you can use EC2 tags to define your cmbootstrap metadata.  This has the advantage that your user data field can both be more compact, and can be identical across *all* of your EC2 instances, regardless of their configuration.  The user data field is then used only to launch cmbootstrap, not to define what configuration to apply to the instance.  It also means that you can easily see what configuration has been applied to a given EC2 instance, from the AWS web console or CLI, simply by viewing the instance's tags.  This is equivalent to the metadata approach used for Google Compute Engine.

The only limitation of this approach is that you must assign your EC2 instance to an instance profile that grants access to read the tags, since EC2 instances are by default not granted access to read their own tags.

When using EC2 tags to define the cmbootstrap configuration, the "core" cmbootstrap configuration metadata (defining organization, project, type and other options) will typically be defined using tags, while the VCS metadata can be defined in the user data field directly, as this is usually standardized and common across all EC2 instances within an AWS account.  Defining this within the user data field prevents the need to duplicate it in tags on every EC2 instance.

The EC2 tags defining the cmbootstrap metadata can then be defined as infrastructure-as-code using CloudFormation, for example:

<pre>
EC2InstanceExample:
  Type: "AWS::EC2::Instance"
    Properties:
      Tags:
        -
          Key: "cm-organization"
          Value: "MyCompany"
        -
          Key: "cm-project"
          Value: "ECommerce_Platform"
        -
          Key: "cm-type"
          Value: "Web_Server"
</pre>

### Google Compute Engine

Configuration management metadata can be defined for Google Compute Engine virtual machines via the instance's metadata.  More information on Google Compute Engine metadata is available here:

<https://cloud.google.com/compute/docs/storing-retrieving-metadata>

Metadata can be set manually via the Google Cloud Console or the <code>gcloud</code> command line, but should ideally be defined using infrastructure-as-code, for example using Google Deployment Manager (YAML format) as follows:

<pre>
metadata:
  items:
    - key: "cm-organization"
      value: "MyCompany"
</pre>

cmbootstrap will automatically detect when it is running on Google Compute Engine, and if detected will make calls to the Google Cloud Platform metadata API endpoints to retrieve the necessary metadata.

### Environment variable based

The technique used above to define cmbootstrap metadata within a Docker container can also be used to control cmbootstrap on any other environment which does not explicitly support metadata, but where you can set environment variables.  For example, you could use cmbootstrap on a bare-metal server installation, by defining environment variables prior to running cmbootstrap.

### Launching cmbootstrap - VMware/VirtualBox

cmbootstrap needs to execute when the virtual machine or container is first launched.  For VMware or VirtualBox based virtual machines, this usually means executing it via <code>/etc/rc.local</code>.  Example code to add to <code>/etc/rc.local</code> is available here:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/launch/rc.local/rc.local.sh>

This code in turn relies on the <code>fetch-cmbootstrap</code> script which must also be installed on the virtual machine, and is available here:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/launch/rc.local/fetch-cmbootstrap>

This script will automatically download the latest cmbootstrap directly from GitHub.  Alternatively, you can save a static copy of cmbootstrap on you virtual machine, and then call this directly from <code>/etc/rc.local</code>. 

### Launching cmbootstrap - Docker

Launching of cmbootstrap within a Docker container is simply performed via a <code>RUN</code> in the Dockerfile, as shown in the example file above.

### Launching cmbootstrap - Amazon EC2

On Amazon EC2, the user data field is used to launch cmbootstrap.  This is equivalent to the startup script on Google Compute Engine described below, except that the user data field serves the dual purposes of both launching cmbootstrap, and specifying the cmbootstrap metadata, as explained above.

An example user data script for launching cmbootstrap on EC2 is available here:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/launch/AWS/user-data-cmbootstrap.sh>

Note that cmbootstrap cannot be specified directly as the user data script, as it will exceed the maximum user data field size imposed by EC2.

### Launching cmbootstrap - Google Compute Engine

For Google Compute Engine, the cmbootstrap script must be run via the "startup script" for the VM.  More information on startup scripts for Google Compute Engine is available here:

<https://cloud.google.com/compute/docs/startupscript>

A simple Compute Engine startup script can be used which combines <code>fetch-cmbootstrap</code> and <code>/etc/rc.local</code> above.  If using CentOS on Google Compute Engine, you can use the following script which provides additional features such as automatic installation of wget, generation of an escaped version of the script for use with Deployment Manager, and automatic labelling of the instance to report cmbootstrap download progress:

<https://github.com/Priocept/cmbootstrap/blob/master/examples/launch/rc.local/fetch-cmbootstrap>

Note that cmbootstrap cannot be specified directly as the startup script, as it may exceed the maximum metadata size limit imposed by Google Compute Engine.

## Metadata Parameters

The following metadata parameters can be used to control the cmbootstrap configuration management process:

|Metadata Name| Description|
|------------- |-------------|
|<code>cm-vcs-repo-base</code>|Version control repository base URL.|
|<code>cm-vcs-repo-base-path</code>|Optional sub-path to be appended after <code>cm-vcs-repo-base</code>.|
|<code>cm-vcs-repo-type</code>|Version control repository type.  <code>Git</code> and <code>Subversion</code> are currently supported.|
|<code>cm-vcs-username</code>|Version control username.|
|<code>cm-vcs-password</code>|Version control password.|
|<code>cm-organization</code>|Organization to which the configuration relates.|
|<code>cm-project</code>|Project to which the configuration relates.|
|<code>cm-type</code>|Specific server (instance) type to which the configuration relates.|
|<code>cm-vcs-revision</code>|Version control revision to use.  Defaults to <code>HEAD</code> if not specified.  This parameter can be used to "lock" a server configuration to a specific configuration management version in the version control system, isolating it from future changes.
|<code>cm-hostname</code>|Hostname.  If specified, a configuration for this specific hostname, one level below the type as a further sub-directory in the version control system, will be retrieved if it exists.
|<code>cm-set-hostname</code>|If set to <code>true</code>, the hostname of the server will be changed to this value during the configuration management process.    Use this value, plus cm-hostname above, to set the hostname for permanent servers which are built from a template VM and so need the default template hostname to be changed.  Defaults to <code>false</code> if not specified.
|<code>cm-args</code>|Additional arguments which are passed to the configuration management process.  These can be used to parameterise and alter the behaviour of the configuration management process, without having to make changes to the Ansible playbooks.  By convention the value should contain semicolon delimited <code>name=value</code> pairs, for example <code>name1=value1;name2=value2</code>, but any format can be used and parsing of the arguments is the responsibility of the configuration management code (Ansible playbooks) which are passed this value by cmbootstrap.
|<code>cm-run-once</code>|If set to <code>false</code>, the configuration management process will run on future reboots, even if it has previously succeeded.  Previous success is recorded by the creation of a file at <code>\$HOME/.cmbootstrap/.success</code>.  If cmbootstrap previously failed (i.e. if the <code>.success</code> file does not exist), the configuration management process will run again on each reboot, regardless of this value.  Defaults to <code>true</code> if not specified.
|<code>cm-disabled</code>|If set to <code>true</code>, the configuration management process is disabled entirely.  Defaults to <code>false</code> if not specified.

## cmbootstrap.cfg

Certain metadata values are typically common across all virtual machines or containers within a given set of infrastructure.  Furthermore, you may want to lock down certain metadata values to enforce a given configuration and prevent alternatives being used.

If cmbootstrap finds a file called <code>cmbootstrap.cfg</code> in the same directory as itself (typically <code>/usr/local/bin/cmbootstrap.cfg</code>, it will read metadata values from this file.  <code>name:value</code> format is expected, with lines starting with <code>#</code> being treated as comments and ignored.  Metadata values defined in <code>cmbootstrap.cfg</code> always override any metadata defined using the techniques described above.

By using <code>cmbootstrap.cfg</code> within your base virtual machine or container image, you can embed a standard configuration for your version control repository location.  This minimises the amount of metadata that you then need to pass to cmbootstrap for each individual virtual machine, with only <code>cm-organization</code>, <code>cm-project</code> and <code>cm-type</code> being required and the rest being specified in <code>cmbootstrap.cfg</code>.

## Overview of Configuration Management Bootstrap Process

The cmbootstrap process consists of the following steps:

1. Virtual machine or container is started.
2. cmbootstrap detects the platform on which it is running and uses the appropriate technique to retrieve the VM's cmbootstrap metadata.
3. cmbootstrap uses this metadata to determine the location of the version control system that contains the configuration management file(s), any credentials that may be required, and the path to the file(s).
4. cmbootstrap retrieves the configuration management file(s) from version control and stores them locally.
5. cmbootstrap launches Ansible in local mode, specifying the retrieved configuration management file(s).
6. cmbootstrap reports success or failure, via a standard set of log files.

This process happens entirely automatically and provided there are no errors in configuration management implementation, will result in the virtual machine arriving in its desired final state, with no manual intervention after initial VM startup.

## cmbootstrap Logging

The cmbootstrap framework logs all of the output from its activities to the following location:

<pre>
$HOME/.cmbootstrap
</pre>

If run as the root user, as normally required to complete configuration management steps, this will be the following location:

<pre>
/root/.cmbootstrap
</pre>

In this directory there will be files prefixed with <code>packages.</code> in relation to software package installations performed by cmbootstrap, <code>ansible.</code> in relation to Ansible task execution, and <code>cmbootstrap.</code> in relation to cmbootstrap itself.

For each type of log file prefix, there will be <code>log</code> and <code>err</code> files.  If the <code>ansible.err</code> and <code>cmbootstrap.err</code> files are zero bytes at the end of the process, then the configuration management was completed successfully.  If they are greater than zero bytes in size, an error occurred.  Any contents of the <code>packages.err</code> can safely be ignored, if present.

Monitoring of a cmbootstrap process that is in progress can be performed by SSH-ing in to the VM while it is running, and using the following commands:

<pre>
tail -f /root/.cmbootstrap/cmbootstrap.log.XXXXXXXXXXXXXX
</pre>
or:
<pre>
tail -f /root/.cmbootstrap/ansible.log.XXXXXXXXXXXXXX
</pre>

Where <code>XXXXXXXXXXXXXX</code> is a unique timestamp for the current run.  The <code>cmbootstrap.log</code> should be monitored initially, followed by <code>ansible.log</code> once <code>cmbootstrap.log</code> indicates that the Ansible part of the process has commenced.

Any old log files from previous runs are moved to a <code>_old</code> sub-directory before a new run is started.  This allows viewing of the previous configuration history.

*Note: It is possible to SSH to a VM shortly after its boot process starts and its network connection comes up.  This way the cmbootstrap process can be monitored as it progresses.  It is not necessary to wait for cmbootstrap to succeed or fail before connecting to the VM.*

## Ansible Playbook File Structure

Each configuration management file in Ansible is known as a "playbook".  By convention, cmbootstrap expects to see the following three playbook files at the determined configuration management location:

1. <code>config.yml</code> - Configuration file that can be included by the following two files, used for configuration and setup that is common to both.  This file is never executed directly by cmbootstrap.
2. <code>init.yml</code> - Initialization playbook.  This playbook is optional but always run first if present, and can be used to download additional playbooks, or perform other tasks that the main playbook relies on.
3. <code>main.yml</code> - Main playbook.  This playbook is run after <code>init.yml</code> and will trigger the main configuration management tasks.

## Development of cmbootstrap Compatible Ansible Playbooks

When developing and testing new Ansible playbooks for use via cmbootstrap, the following techniques and cmbootstrap features can be used to streamline the development process.

### Local Ansible execution

Playbooks can be run manually and locally on any environment on which Ansible is installed by using the following command:

<pre>
ansible-playbook --connection=local <playbook_file>
</pre>

Note, however, that if playbooks are run in this manner, the cmbootstrap metadata described above will not be available to the playbooks.

### Running cmbootstrap against local playbooks

By default, cmbootstrap will retrieve playbooks to run from the specified version control system.  However, during development, it is inefficient to check every file change into version control before being able test it.  Therefore, if cmbootstrap detects playbooks at the following locations:

<pre>
/tmp/cmbootstrap/init.yml
/tmp/cmbootstrap/main.yml
</pre>

It will run this playbook instead of retrieving from version control.

In this case, development of playbooks can take place without checking them into version control until they are tested.  To further streamline the process, the path <code>/tmp/cmbootstrap</code> can be made a version control local working copy, allowing an easy commit back to version control when testing is completed.

### Direct running of cmbootstrap

cmbootstrap can be manually run at any time, simply by running <code>cmbootstrap</code> from the command line.  The command is typically installed to this location:

<pre>
/usr/local/bin/cmbootstrap
</pre>

Which makes it accessible to run without specifying the full path.

The command can also be run with the <code>-</code> parameter, as follows:

<pre>
cmbootstrap -
</pre>

This causes cmbootstrap to direct all of its output to standard output (<code>stdout</code> and <code>stderr</code>) rather than to the log files described above.  Use this option when developing and debugging a new set of configuration management files.

## Google Compute Engine status labelling

When running on Google Compute Engine, cmbootstrap provides additional functionality whereby it will label the compute instance that it is running on, to report progress on the configuration process.  This allows quick viewing of the configuration management status from the Google Cloud Platform web console (or the <code>gcloud</code> command line interface) without having to SSH into the virtual machine to check the cmbootstrap logs.

This feature is currently not supported on other platforms but equivalent functionality to add EC2 tags to report cmbootstrap status (subject to the EC2 instance having appropriate permissions) will be added in the near future.

