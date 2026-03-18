module.exports = {
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          { key: "Access-Control-Allow-Origin", value: "*" },
        ],
      },
    ]
  },
  rewrites() {
    return [
      {
        source: "/doc",
        destination: "/doc/index.html"
      }
    ]
  }
}
