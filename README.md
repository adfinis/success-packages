# Success packages

This repo contains presentations for the [Adfinis](https://adfinis.com/) success packages.

Content available [here](https://adfinis.github.io/success-packages/index/#/).

## Testing

It's possible to generate the **reveal-md** slides locally for testing, run:
``` sh
for file in *.md ; do /usr/local/bin/reveal-md --static output/"${file%.*}" "${file}" ; done
```
