job "example" {
  datacenters = ["dc1"]
  type = "batch"

  group "example" {
    task "example" {
      driver = "exec"

      config {
        command = "/bin/cat"
        args = ["/proc/self/cgroup"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
