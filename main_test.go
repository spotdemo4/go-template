package main

import "testing"

func TestHello(t *testing.T) {
	expected := "Hello, world!"
	result := hello("world")
	if result != expected {
		t.Errorf("hello(%q) = %q; want %q", "world", result, expected)
	}
}
