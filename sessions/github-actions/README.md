# GitHub Actions Intro

- Hosted runners
- Linux and Windows
- YAML Workflow syntax
- In repo: `/.github/workflows`

## Basic GitHub Action

Walk through [hello-world.yaml](../../.github/workflows/hello-world.yaml)

- `on` triggers include push, cron, PR and issue comments
- jobs run concurrently, or can have dependencies defined
- jobs can have multiple consecutive steps

> Edit [run-hello-world.txt](run-hello-world.txt) and push to start; browse to https://github.com/sixeyed/docker-birthday-7

## Docker GitHub Action

Walk through [pi.yaml](../../.github/workflows/pi.yaml)

- any image on Docker Hub
- can specify env & args
- GH repo mounted as bind

> Edit [run-pi.txt](run-pi.txt) and push to start; browse to https://github.com/sixeyed/docker-birthday-7

##

Badges! Add from run to 

## Something more complex...

Walk through [aks-deploy.yaml](./samples/aks-deploy.yaml), and the [Dockerfile](./samples/aks-create-cluster/Dockerfile).
