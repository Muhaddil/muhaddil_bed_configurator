"use client"

import { motion } from "framer-motion"
import { useTheme, themes } from "../context/ThemeContext"
import { Check } from "lucide-react"

export default function ThemeSelector({ onClose }) {
  const { theme, changeTheme } = useTheme()
  const currentTheme = themes[theme]

  const themeList = Object.entries(themes).map(([key, value]) => ({
    id: key,
    ...value,
  }))

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9, y: -10 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.9, y: -10 }}
      className="pointer-events-auto absolute top-16 left-0 rounded-xl backdrop-blur-xl border shadow-2xl p-3 z-50"
      style={{
        backgroundColor: currentTheme.surface,
        borderColor: currentTheme.border,
      }}
    >
      <div className="space-y-2 min-w-[200px]">
        {themeList.map((t) => (
          <motion.button
            key={t.id}
            whileHover={{ x: 5 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => {
              changeTheme(t.id)
              onClose()
            }}
            className="w-full flex items-center gap-3 px-4 py-2 rounded-lg border transition-all text-left"
            style={{
              backgroundColor: theme === t.id ? `${t.primary}20` : currentTheme.background,
              borderColor: theme === t.id ? t.primary : currentTheme.border,
              color: theme === t.id ? t.primary : currentTheme.textSecondary,
            }}
          >
            <div className="flex-1">
              <p className="text-sm font-semibold">{t.name}</p>
            </div>
            {theme === t.id && <Check size={16} />}
          </motion.button>
        ))}
      </div>
    </motion.div>
  )
}
