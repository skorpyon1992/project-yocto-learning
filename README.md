# project-yocto-learning

In order to prepare the Yocto build you have to execute the following command:

```./build.sh -a -m <machine> prepare```

For example _./build.sh -a -m raspberrypi3 prepare_. This will download necessary repositories and add proper configuration.

To build the image and create final .direct file :

```./build.sh -a build```


To flash the image to the SD card:

```./build.sh flash```

You will be prompted to select the SD card partition and .direct image.



#### Notes

Only support for raspberry pi series is available for the moment.

If you remove *-a* option from the commands, the learning yocto layer
won't be cloned, the bblayer and local conf must be set manually, and
core-image-minimal will be built.