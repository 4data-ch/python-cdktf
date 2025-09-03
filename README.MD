### CDKTF Toolchain for Python

This image is designed to provide a working environment in which to run terraform and it's cdktf tools but geared specifically
towards terraform code generation only.

https://developer.hashicorp.com/terraform/cdktf 


#### Build

To build this image locally:

```bash
docker build --tag <image:version> .
```

#### License

As this work is simply a packaging of Hashicorp's cdktf and terraform toolchains, it is subject to their license terms (see LICENSE file for details)
