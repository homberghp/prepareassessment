# prepare-assessment
Prepare a performance assessment on USB sticks and centralized correction work afterwards.

## summary
Take exams using a controlled environment on candidate owned laptops.
This scripts and ideas in this repository allow the creation of USB sticks during exams, which provide a controlled environment and into which exam task can be injected before and from which exam work can be harvested after the exam session.
The boot medium in a live xubuntu and works on most PC, including Apple-intel platforms, once you know how to convince your machine to boot from the stick. 

After the exam, the student work can be corrected. For that we use a _correctors workbench_ which help in efficiently correcting an exam with a lot of individual files. Thing of a complete java project with quite some files and some tasks per file.

## short context
At the Fontys Hogeschool voor Techniek en Logistiek in Venlo, The Netherlands we use a so called
performance assessment.

A performance assessment is a electronic exam, in which the students work with a computer with a complete set of
tools that would nromally be used using software development. In case the student uses a linux/ubuntu variant on his machine,
the match is exact.

In an exam however, you want to have control over what the student can access from his exam machine during the exam.
In particular you do not want to allow access to The Internet, nor any other network, unless you control it by yourselves.
The solution is a dual boot, in which the institute provides the boot medium, in our case a USB stick.

The preparation of the USB stick is somewhat involved, which is why I want to share it with my colleague teachers.

The preparation of the image to be put on the stick has started with customizer, a ISO life image creator, also  found on github. In our current setting, the important parts of the ISO file system are the casper image, the initrd file and the boot scripts, which support traditional bios boot and UEFI boot. On Windows only laptops you may have to turn of secure boot and or fast-boot to be able to boot from the stick.


## stick preparation.
The preparation of a USB stick consists of two steps:

1. Prepare the base image. This needs to be done once to make the stick usable and otherwise everey time you want to update the base image. The base image can be reused between exam. The program involved is `bin/prepareSticks`.
2. Insert the exam environment and home directory for the exam candidate. This is done once per exam and inserts a fresh home directory into the stick, erasing any earlier work and insert both a local repository and a checked out sandbox as exam into the stick. The snadbox is conected to the local repository, so that the candidate has a limit backup for the case that he or she screws up the exam environment or an earlier solution.

In both cases we use a set of USB-3.0 hubs which parallelize the copying of the data to the sticks. Typically we write
batches of 14 sticks. For step 1 we can prepare 14 sticks in about 3 minutes, for setp 2 it takes 20 seconds, and another 30 seconds to connect the next batch of sticks to the hubs.

We have good experience with Anker 7 USB prt USB hubs type H7928-U3 see http://www.anker.com/product/68UNHUB-B7U.
The USB sticks are essential to get the kinds of speeds we observe. We use sandisk Extreme USB 3.0 sticks, typically the 16GB variant. Having bigger versions is not necessary but adds speed, typically double for the 32 GB version and 3 times in the 64GB variant. At the time of writing a 16GB stick does about € 20.  see https://www.sandisk.com/home/usb-flash/extreme-usb for specs, local dealer for prices.

