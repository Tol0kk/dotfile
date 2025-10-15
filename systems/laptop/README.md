# SSD Formating

Format SSD to use 4096 sector

[OpenZFS Documentation](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Hardware.html#nvme-low-level-formatting)

```sh
nvme format /dev/nvme1n1 -l $ID
```

The $ID corresponds to the Id field value from the Supported LBA Sizes SMART information.
