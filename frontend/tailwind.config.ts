import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["var(--font-inter)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "ui-monospace", "SFMono-Regular", "monospace"],
      },
      colors: {
        base: {
          950: "#0a0e14",
          900: "#0d1219",
          850: "#111826",
          800: "#161f2e",
          700: "#1e2a3d",
          600: "#2a3a52",
          500: "#3d5170",
        },
        ink: {
          100: "#e8edf5",
          300: "#aeb9c9",
          500: "#7c8aa0",
          600: "#5a677c",
        },
        signal: {
          teal: "#2dd4bf",
          blue: "#3b82f6",
          amber: "#f5a524",
          red: "#f43f5e",
          green: "#22c55e",
        },
      },
      boxShadow: {
        glow: "0 0 0 1px rgba(45,212,191,0.15), 0 0 24px -6px rgba(45,212,191,0.35)",
        card: "0 1px 0 0 rgba(255,255,255,0.03) inset, 0 8px 24px -12px rgba(0,0,0,0.6)",
      },
      animation: {
        "pulse-slow": "pulse 2.5s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        "slide-in": "slideIn 0.35s ease-out",
        "fade-in": "fadeIn 0.4s ease-out",
      },
      keyframes: {
        slideIn: {
          "0%": { transform: "translateY(-8px)", opacity: "0" },
          "100%": { transform: "translateY(0)", opacity: "1" },
        },
        fadeIn: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
