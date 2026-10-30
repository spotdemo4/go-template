package main

import (
	"context"
	"fmt"
	"os"

	"github.com/urfave/cli/v3"
)

func main() {
	cmd := &cli.Command{
		Usage: "say hello",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:  "name",
				Value: "world",
				Usage: "who to greet",
			},
		},
		Action: func(_ context.Context, cmd *cli.Command) error {
			fmt.Println(hello(cmd.String("name")))
			return nil
		},
	}

	if err := cmd.Run(context.Background(), os.Args); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func hello(name string) string {
	return fmt.Sprintf("Hello, %s!", name)
}
