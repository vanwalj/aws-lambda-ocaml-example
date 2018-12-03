## What ?

You may already heard about it, but since the end of november 2018 it is possible to run lambda using 100% custom code, the only thing you have to provide is a zip folder containing a binary named bootstrap which will get executed and should reply to lambda calls. I might write technical details about it, but for now, if you want to know about the internals, I encourage you to look at the code contained within the aws-lambda opam package :)

## Deploy a lambda function using native Ocaml code step by step

### Requirements

- An AWS Linux machine or Docker to compile everything
- The aws-cli tools to deploy everything

### Step 1: Clone this repo

If you just want to see it running, just clone this repo and `cd` inside

### Step 2: Build everything

This repo contains a ready to use `Dockerfile` to compile the code so it will run properly on AWS Lambda but first, you'll need to build it, so just run

```bash
docker build -t dune-builder .
```

Then simply run the container

```bash
docker run \
  --rm \
  -v ${PWD}:/home/opam/opam-repository:rw \
  -it dune-builder /bin/sh -c "opam install --deps-only . && make"
```

It should mount the current folder, install the opam deps and compile everything to a native binary

So now, just make a `dist` folder

```bash
mkdir dist
```

and copy and rename that binary to bootstrap

```bash
cp ./_build/default/handler/src/handler.exe dist/bootstrap
```

We are now ready to push everything to AWS!

### Step 3: Push it !

We'll use `cloudformation` and `aws-cli` to deploy everything, make sure you already provided your aws credentials to `aws-cli`, if not, simply run `aws configure` and follow the steps.

First we'll need to create an S3 bucket to host our code, you can go to the AWS Web UI or simply run this after you replaced `the-name-of-your-code-bucket` with a name of your choice

```bash
aws s3 mb s3://[the-name-of-your-code-bucket]
```

It should simply create a bucket

Once done, we'll use the `aws cloudformation package` command to transform our `template.yml` file into a `cloudformation` ready file and zip and upload our code to S3
So just replace `[the-name-of-your-code-bucket]` with your S3 bucket name and run

```bash
aws cloudformation package \
  --template-file template.yaml \
  --output-template-file serverless-output.yaml \
  --s3-bucket [the-name-of-your-code-bucket]
```

Finally, we just have to deploy our `cloudformation` stack, just run

```bash
aws cloudformation deploy \
  --template-file serverless-output.yaml \
  --capabilities CAPABILITY_IAM \
  --stack-name aws-lambda-ocaml
```

And wait for it to complete.

Congrats ! You should now have a running Lambda that execute a native Ocaml binary !

Now it's up to you to hack things around, edit the `handler/src/handler.ml` file to execute your own code and if anything went wrong, feel free to open an issue, i'll be more than happy to help
