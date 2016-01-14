# very short docu, most likely not yet complete

The work flow assumes svn as repository technology. You can do
without.

The script ./makerepos.pl creates a set of repositories for an exam project a.k.a. performance assessment.

You execute this script in a directory containing the following:
../default.properties defines the properties of the project like id, module.
    formatted like a java .properties file. Interal documentation allowed.

===== optional files in the current dir =====
examproject      a netbeans type java project with a nbproject/project.xml file defining the 
		 top level properties (name etc) of the project.

project.xml_template  a project.xml template which will be copied with the name of the 
		      project set to the name of the candidate.

api.zip		      The javadoc of an optinal api the candidates have on the website.

jar		      The jars belonfing to the project but not in the repos.

web		      Exam specific stuff that should go into the website.

web/docblock.html     The additional data used to describe (and link to) the content of the jar dir.
		      The file can also link to the other files in e.g. the web dir. 
		      The php script index.php that will also land in the web dir will place this 
		      block just above the table with the candidate names and the url to the individual
		      repositories.

==== created are ====
standard output.      Redirect that to some file that is to be executed as root or apache user.
	 	      Redirect it to your favorite script name like doit.

htpasswd.exam	      The exam password file used for basic authentication to web and repos.

'apache'.conf 	      file an apache conf file named something like SEN1-2011-06-15.conf

settings.php	      The settings in php format used in the website 

SVN details:	      The script by default (and currently only) way of creating repositories is one
    		      repository per candidate with a shared authz file for all. 
		      Rationale: svn support atomic operations meaning that it will do some kind of locking
		      per repository. In this way we can support a higher concurrency and ensures that the
		      candidate commits do not have to wait for each other. As an added benefit you can easily 
		      see from revision number of the repositories which candidates were productive and for 
		      which do not even have to bother to open their project. The revision number of the 
		      repositories all start with 1, because they minimally have a trunk subdir and optionally 
		      a project within that trunk.

===== resources used ====
In the directory /usr/local/prepareassessment/resources you find a few files that are used 
and copied to the exam specific website.

index.php             The script that includes settings.php to set title etc and processes file 
		      svn_repos.txt which contains the candidate data and repo urls details.

index_template.html   Included by index.php to separate html layout from the index.php file.

