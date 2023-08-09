# AutoCICD
Setup CI/CD using Github Actions and deploy to ec2 t2-micro instance.

#### Note: This only works for [NestJS](https://nestjs.com/), [NextJS](https://nextjs.org/), [NodeJS](https://nodejs.org/en), [Java Springboot](https://spring.io/projects/spring-boot) and [Strapi](https://strapi.io/) projects

## Usage
Mostly you will need to edit files in config folder, providing credentials.
Sometimes optionally you might need to edit files in workflows folder to update
workflow files / deployment scripts depending on need.

## Description of Config Files
 * [config](./config)
   * [aws.py](./config/aws.py)          -> AWS Credentias: ACCESS KEY ID and SECRET ACCESS KEY for an IAM user with access to EC2
   * [general.py](./config/general.py)      -> General info required: type of project (nest/next/node/springboot/strapi) and github private SSH key file location
   * [repository.py](./config/repository.py)   -> Repository details: URL/Location of repo

These are the required config variables are required to be set but rest can be changed on a per need basis.

## Requirements to run this project
* Python should be available and required packages should be installed
* AWS CLI should be installed
* Git should be installed
