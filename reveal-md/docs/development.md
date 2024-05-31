# Testing

We are using [reveal-md](https://github.com/webpro/reveal-md), which is a fork of [reveal-js](https://revealjs.com/). 

Make sure to locally install the same version of `reveal-md` as present in `.github/workflows/revealmd.yaml`.

At time of writing, run: `npm install -g reveal-md@5.5.2`.

It's possible to generate the **reveal-md** slides locally for testing, run:

```sh
for file in *.md ; do reveal-md --static output/"${file%.*}" "${file}" ; done
```

You can also export a single presentation, for example:

```sh
reveal-md --static output/hashicorp-vault-administration hashicorp-vault-administration.md
```

# Configuration

You can configure the behaviour of the presentations by placing configuration options in `reveal.json` and/or `reveal-md.json` and using the `reveal-md --template` flag.

You can choose to add configuration to each individual presentation. For example, by manually embedding `reveal-md/css/custom.css` in the presentation. Take any `*.md` file as an example.