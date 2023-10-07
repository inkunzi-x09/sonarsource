# Running Docker applications on ECS clusters

There are some prerequisites to put in place.

## Step 1: Create a simple node app

In a folder that you want, run the following commands :

```sh
npm init --y
npm install express
```

Then, create an index.js file with the following code :

```sh
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
```

You can test the app running :

```sh
node index.js
```

## Step 2: Create a Dockerfile for the app

```sh
# Pull the Node.js image
FROM node:18-alpine

# Create a Docker working directory
WORKDIR /app

# Copy package.json and package-lock.json dependencies files 
COPY package*.json ./

# Install dependencies inside Docker
RUN npm install

# Copy the application source code
COPY . .

# Port number to expose the Node.js app outside of Docker
EXPOSE 3000

# Command to run the application
CMD ["node", "index.js"]
```

Then, build the image:

```sh
docker build -t sonar-app .
```

Finally, expose the container to run the image on URL: http://localhost:3000

```sh
docker run -it -p 3000:3000 sonar-app
```

## Step 3: Push your image in an ECR repository

After all the previous steps, you have to push the image on the ECR repository created (in Terraform). These are the steps :

Run an authentication token that authenticates and cnnects the docker client to your registry repository:

```sh
aws ecr get-login-password --region us-east-1
```

Copy the output token. Now enter the following command including your URI and token:

```sh
aws ecr --region us-east-1| docker login -u AWS -p <encrypted_token> <repo_uri>
```

The output should show "Login Succeed!" Now we need to tag the image so it can be pushed to the repo. To do so enter the following command using your image name and ECR repository URI:

```sh
docker tag centos <target_ecr_repo_uri>
docker push <ecr-repo-uri>
```

Now, you can write the Terraform code to expose your aplication on the cloud.