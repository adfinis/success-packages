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

You can also export a single presentation, for example:
```sh
reveal-md --static output/hashicorp-vault-administration hashicorp-vault-administration.md
```

## Configuration

We are using [reveal-md](https://github.com/webpro/reveal-md), which is a fork of [reveal-js](https://revealjs.com/) that adds improvements on top.

You can configure the behaviour of the presentations by placing configuration options in `reveal.json` and/or `reveal-md.json`. If those files are blank, it means no configuration is currently active and applied to (all) presentations.

You can choose to add configuration to each individual presentation. For example, by manually embedding `custom.css` in the presentation. Take the header of `hashicorp-vault-administration.md` as an example.