"use client"

import { createContext, useContext, useState, useEffect } from "react"

const ThemeContext = createContext()

export const themes = {
  dark: {
    name: "Dark",
    primary: "#4ade80",
    secondary: "#38bdf8",
    accent: "#fbbf24",
    background: "rgba(10, 10, 15, 0.8)",
    surface: "rgba(20, 20, 30, 0.6)",
    text: "#f0f0f0",
    textSecondary: "#a0a0a0",
    border: "rgba(255, 255, 255, 0.1)",
    success: "#10b981",
    error: "#ef4444",
    warning: "#f59e0b",
  },
  light: {
    name: "Light",
    primary: "#059669",
    secondary: "#0284c7",
    accent: "#d97706",
    background: "rgba(245, 245, 250, 0.95)",
    surface: "rgba(255, 255, 255, 0.8)",
    text: "#1f2937",
    textSecondary: "#6b7280",
    border: "rgba(0, 0, 0, 0.1)",
    success: "#10b981",
    error: "#dc2626",
    warning: "#d97706",
  },
  neon: {
    name: "Neon",
    primary: "#00ff88",
    secondary: "#00d4ff",
    accent: "#ff006e",
    background: "rgba(5, 5, 20, 0.9)",
    surface: "rgba(15, 15, 35, 0.7)",
    text: "#00ff88",
    textSecondary: "#00d4ff",
    border: "rgba(0, 255, 136, 0.2)",
    success: "#00ff88",
    error: "#ff006e",
    warning: "#ffaa00",
  },
  cyberpunk: {
    name: "Cyberpunk",
    primary: "#ff006e",
    secondary: "#8338ec",
    accent: "#ffbe0b",
    background: "rgba(20, 0, 40, 0.85)",
    surface: "rgba(40, 10, 60, 0.7)",
    text: "#ff006e",
    textSecondary: "#8338ec",
    border: "rgba(255, 0, 110, 0.2)",
    success: "#3a86ff",
    error: "#ff006e",
    warning: "#ffbe0b",
  },
}

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState("dark")

  useEffect(() => {
    const savedTheme = localStorage.getItem("nui-theme") || "dark"
    setTheme(savedTheme)
    document.documentElement.setAttribute("data-theme", savedTheme)
  }, [])

  const changeTheme = (newTheme) => {
    setTheme(newTheme)
    localStorage.setItem("nui-theme", newTheme)
    document.documentElement.setAttribute("data-theme", newTheme)
  }

  return <ThemeContext.Provider value={{ theme, changeTheme, themes }}>{children}</ThemeContext.Provider>
}

export function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error("useTheme must be used within ThemeProvider")
  }
  return context
}

export default ThemeProvider
