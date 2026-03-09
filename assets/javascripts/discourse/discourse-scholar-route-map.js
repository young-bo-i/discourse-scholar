export default function () {
  this.route("scholar", { path: "/scholar" }, function () {
    this.route("paper", { path: "/paper/:paperId" });
    this.route("author", { path: "/author/:authorId" });
    this.route("search", { path: "/search" });
  });
}
