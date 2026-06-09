FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY prisma ./prisma
RUN npx prisma generate
COPY src ./src
COPY public ./public
COPY docs ./docs
EXPOSE 3000
CMD ["npm", "run", "prod:start"]
