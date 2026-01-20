# multi-stage: build frontend, then production node server
FROM node:20-alpine AS builder
WORKDIR /app

# copy root package.json to install concurrently if needed (not necessary in final)
COPY package.json ./

# build frontend
COPY frontend ./frontend
WORKDIR /app/frontend
RUN npm ci
RUN npm run build

# production image
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# copy backend
COPY backend ./backend
# copy frontend build
COPY --from=builder /app/frontend/dist ./backend/public

WORKDIR /app/backend
RUN npm ci --only=production

EXPOSE 4000
CMD ["node", "server.js"]
