FROM timbru31/node-alpine-git
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
EXPOSE 3005
CMD ["npm","start"] 
