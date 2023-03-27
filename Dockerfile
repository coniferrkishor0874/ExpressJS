FROM node:16-alpine 

WORKDIR /app

RUN npm i npm@latest -g

COPY package*.json  ./

RUN npm install 

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
