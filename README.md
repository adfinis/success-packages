# Success packages

This repo contains presentations for the [Adfinis](https://adfinis.com/) success packages.

Content available [here](https://adfinis.github.io/success-packages/index/#/).

## Testing

Make sure to locally install the same version of `reveal-md` as present in `.github/workflows/revealmd.yaml`.

At time of writing, run: `npm install -g reveal-md@5.3.4`.

It's possible to generate the **reveal-md** slides locally for testing, run:
```sh
for file in *.md ; do reveal-md --static output/"${file%.*}" "${file}" ; done
```
