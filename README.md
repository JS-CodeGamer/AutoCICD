# AutoCICD
Setup CI/CD using Github Actions and deploy to ec2 t2-micro instance.

#### Note: This only works for [NestJS](https://nestjs.com/), [NextJS](https://nextjs.org/), [NodeJS](https://nodejs.org/en), [Java Springboot](https://spring.io/projects/spring-boot) and [Strapi](https://strapi.io/) projects

## Usage
You need to edit files in config folder, providing credentials mostly and sometimes
optionally edit files in workflow folder to update workflow files / deployment scripts

Also you need to specify type in config/general.py which should correspond to a name
of directory (keep in mind this name is case sensitive) in workflows directory which
will be used
