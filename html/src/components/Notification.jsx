"use client"

import { useEffect } from "react"
import { motion } from "framer-motion"
import { CheckCircle, XCircle, Info, AlertTriangle, X } from "lucide-react"
import { useTheme, themes } from "../context/ThemeContext"

const notificationConfig = {
  success: {
    icon: CheckCircle,
  },
  error: {
    icon: XCircle,
  },
  info: {
    icon: Info,
  },
  warning: {
    icon: AlertTriangle,
  },
}

export default function Notification({ type, title, message, onClose }) {
  const { theme } = useTheme()
  const currentTheme = themes[theme]
  const config = notificationConfig[type] || notificationConfig.info
  const Icon = config.icon

  const getColorForType = () => {
    switch (type) {
      case "success":
        return currentTheme.success
      case "error":
        return currentTheme.error
      case "warning":
        return currentTheme.warning
      case "info":
      default:
        return currentTheme.secondary
    }
  }

  const notificationColor = getColorForType()

  useEffect(() => {
    const timer = setTimeout(() => {
      onClose()
    }, 4000)

    return () => clearTimeout(timer)
  }, [onClose])

  return (
    <motion.div
      initial={{ opacity: 0, x: 50, scale: 0.95 }}
      animate={{ opacity: 1, x: 0, scale: 1 }}
      exit={{ opacity: 0, x: 50, scale: 0.95 }}
      transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
      className="absolute top-6 right-6 pointer-events-auto select-none"
    >
      <motion.div
        className="rounded-2xl p-4 shadow-2xl border-l-4 max-w-sm relative overflow-hidden backdrop-blur-xl"
        style={{
          backgroundColor: currentTheme.surface,
          borderColor: notificationColor,
          borderLeftWidth: "4px",
          boxShadow: `0 8px 32px ${notificationColor}20, 0 0 0 1px ${currentTheme.border}`,
        }}
        whileHover={{ scale: 1.02 }}
      >
        <motion.div
          className="absolute inset-0"
          style={{
            background: `linear-gradient(135deg, ${notificationColor}15, transparent)`,
          }}
          animate={{
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 2,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
          }}
        />

        <div className="relative z-10 flex items-start gap-3">
          <motion.div
            initial={{ scale: 0, rotate: -180 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{ delay: 0.1, type: "spring", stiffness: 200 }}
          >
            <Icon className="w-6 h-6 shrink-0" style={{ color: notificationColor }} />
          </motion.div>

          <div className="flex-1 min-w-0">
            <motion.h4
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.15 }}
              className="text-sm font-bold mb-1"
              style={{ color: notificationColor }}
            >
              {title}
            </motion.h4>
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.2 }}
              className="text-xs leading-relaxed"
              style={{ color: currentTheme.textSecondary }}
            >
              {message}
            </motion.p>
          </div>

          <motion.button
            whileHover={{ scale: 1.1, rotate: 90 }}
            whileTap={{ scale: 0.9 }}
            onClick={onClose}
            className="shrink-0 w-6 h-6 rounded-full flex items-center justify-center transition-colors"
            style={{
              backgroundColor: `${currentTheme.primary}10`,
              color: currentTheme.textSecondary,
            }}
          >
            <X className="w-3.5 h-3.5" />
          </motion.button>
        </div>

        <motion.div
          className="absolute bottom-0 left-0 h-1 rounded-full"
          style={{ backgroundColor: notificationColor }}
          initial={{ width: "100%" }}
          animate={{ width: "0%" }}
          transition={{ duration: 4, ease: "linear" }}
        />
      </motion.div>
    </motion.div>
  )
}
