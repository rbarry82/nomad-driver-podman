package main

import (
	"github.com/hashicorp/go-hclog"
	_ "github.com/hashicorp/nomad/api"
	"github.com/hashicorp/nomad/plugins"
)

func main() {
	// Serve the plugin
	plugins.Serve(factory)
}

// factory returns a new instance of the LXC driver plugin
func factory(log hclog.Logger) interface{} {
	return NewPodmanDriver(log)
}
