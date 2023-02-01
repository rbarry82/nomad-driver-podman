// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package api

import (
	"context"
	"fmt"
	"net/http"
)

// ContainerKill sends a signal to a container
func (c *API) ContainerKill(ctx context.Context, name string, signal string) error {

	res, err := c.Post(ctx, fmt.Sprintf("/v1.0.0/libpod/containers/%s/kill?signal=%s", name, signal), nil)
	if err != nil {
		return err
	}

	defer ignoreClose(res.Body)

	if res.StatusCode == http.StatusNoContent {
		return nil
	}
	return fmt.Errorf("cannot kill container, status code: %d", res.StatusCode)
}
