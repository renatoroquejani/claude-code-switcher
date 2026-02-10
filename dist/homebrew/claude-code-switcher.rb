# typed: false
# frozen_string_literal: true

class ClaudeCodeSwitcher < Formula
  desc "Bash CLI tool to switch Claude Code between LLM providers"
  homepage "https://github.com/renatobohler/claude-code-switcher"
  url "https://github.com/renatobohler/claude-code-switcher/archive/refs/tags/v2.2.0.tar.gz"
  sha256 ""  # Will be updated on release
  license "MIT"

  depends_on "jq"

  def install
    bin.install "bin/claude-switch"
    etc.install "config/api-keys.env.example" => "claude-code-switcher/api-keys.env.example"
    bash_completion.install "dist/homebrew/completions.bash" => "claude-switch"
    zsh_completion.install "dist/homebrew/completions.zsh" => "_claude-switch"
  end

  test do
    system "#{bin}/claude-switch", "help"
  end
end
