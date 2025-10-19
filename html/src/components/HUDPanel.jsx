"use client"

import { motion } from "framer-motion"
import { Camera, RotateCw, MoveVertical, Check, X } from "lucide-react"
import { useTheme, themes } from "../context/ThemeContext"
import { useLocale } from "../context/LocaleContext"

const typeColors = {
  bed: {
    icon: "🛏️",
  },
  monitor: {
    icon: "📺",
  },
  pager: {
    icon: "📟",
  },
}

export default function HUDPanel({ configType, title, coords }) {
  const { theme } = useTheme()
  const { t } = useLocale()
  const currentTheme = themes[theme]

  const controls = [
    { icon: Camera, label: t("label_camera"), description: t("control_camera_desc") },
    { icon: RotateCw, label: t("label_wheel_arrows"), description: t("control_rotate_desc") },
    { icon: MoveVertical, label: t("label_up_down"), description: t("control_height_desc") },
    { icon: Check, label: t("label_enter"), description: t("control_save_desc") },
    { icon: X, label: t("label_esc"), description: t("control_cancel_desc") },
  ]

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2,
      },
    },
  }

  const itemVariants = {
    hidden: { opacity: 0, x: -20 },
    visible: {
      opacity: 1,
      x: 0,
      transition: { duration: 0.4, ease: "easeOut" },
    },
  }

  return (
    <motion.div
      initial={{ opacity: 0, x: -40 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -40 }}
      transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
      className="absolute top-6 left-6 flex flex-col gap-4 pointer-events-none select-none"
    >
      <motion.div
        initial={{ scale: 0.95, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.3 }}
        className="pointer-events-auto rounded-2xl p-6 shadow-2xl border backdrop-blur-xl relative overflow-hidden"
        style={{
          backgroundColor: currentTheme.surface,
          borderColor: currentTheme.border,
          boxShadow: `0 8px 32px ${currentTheme.primary}20, 0 0 0 1px ${currentTheme.border}`,
        }}
      >
        <motion.div
          className="absolute inset-0 opacity-30"
          style={{
            background: `linear-gradient(135deg, ${currentTheme.primary}20, ${currentTheme.secondary}20)`,
          }}
          animate={{
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{
            duration: 3,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
          }}
        />

        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-6 pb-4 border-b" style={{ borderColor: currentTheme.border }}>
            <motion.div
              className="w-1.5 h-6 rounded-full"
              style={{ backgroundColor: currentTheme.primary }}
              animate={{
                opacity: [1, 0.5, 1],
                scaleY: [1, 0.8, 1],
              }}
              transition={{
                duration: 2,
                repeat: Number.POSITIVE_INFINITY,
                ease: "easeInOut",
              }}
            />
            <div>
              <h2 className="text-lg font-bold tracking-wider uppercase" style={{ color: currentTheme.primary }}>
                {title}
              </h2>
              <p className="text-xs" style={{ color: currentTheme.textSecondary }}>
                {typeColors[configType]?.icon} {configType.toUpperCase()}
              </p>
            </div>
          </div>

          <motion.div className="space-y-2" variants={containerVariants} initial="hidden" animate="visible">
            {controls.map((control, index) => (
              <motion.div key={control.label} variants={itemVariants} className="flex items-center gap-3 group">
                <motion.div
                  whileHover={{ scale: 1.05, x: 5 }}
                  className="px-3 py-2 rounded-lg border transition-all flex-shrink-0"
                  style={{
                    backgroundColor: currentTheme.background,
                    borderColor: currentTheme.border,
                  }}
                >
                  <span className="text-xs font-bold" style={{ color: currentTheme.primary }}>
                    {control.label}
                  </span>
                </motion.div>
                <div className="flex items-center gap-2 flex-1">
                  <control.icon size={16} style={{ color: currentTheme.textSecondary }} />
                  <span className="text-xs" style={{ color: currentTheme.textSecondary }}>
                    {control.description}
                  </span>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </motion.div>

      <motion.div
        initial={{ scale: 0.95, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.3 }}
        className="pointer-events-auto rounded-2xl p-6 shadow-2xl border backdrop-blur-xl relative overflow-hidden"
        style={{
          backgroundColor: currentTheme.surface,
          borderColor: currentTheme.border,
        }}
      >
        <motion.div
          className="absolute inset-0"
          style={{
            background: `linear-gradient(135deg, ${currentTheme.secondary}10, transparent)`,
          }}
          animate={{
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{
            duration: 4,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
          }}
        />

        <div className="relative z-10">
          <h3
            className="text-sm font-bold tracking-wider uppercase mb-4 flex items-center gap-2 pb-3 border-b"
            style={{ color: currentTheme.primary, borderColor: currentTheme.border }}
          >
            <motion.div
              className="w-2 h-2 rounded-full"
              style={{ backgroundColor: currentTheme.secondary }}
              animate={{
                scale: [1, 1.2, 1],
                opacity: [1, 0.7, 1],
              }}
              transition={{
                duration: 2,
                repeat: Number.POSITIVE_INFINITY,
              }}
            />
            {t("label_coordinates")}
          </h3>

          <div className="grid grid-cols-2 gap-3">
            {[
              { label: "X", value: coords.x, color: currentTheme.error },
              { label: "Y", value: coords.y, color: currentTheme.success },
              { label: "Z", value: coords.z, color: currentTheme.secondary },
              { label: "H", value: coords.h, color: currentTheme.accent },
            ].map((coord, index) => (
              <motion.div
                key={coord.label}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.3 + index * 0.05 }}
                className="rounded-lg p-3 border transition-all hover:scale-105"
                style={{
                  backgroundColor: currentTheme.background,
                  borderColor: currentTheme.border,
                }}
              >
                <div className="flex justify-between items-center">
                  <span className="text-xs font-bold" style={{ color: coord.color }}>
                    {coord.label}
                  </span>
                  <motion.span
                    key={coord.value}
                    initial={{ opacity: 0, y: -5 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-xs font-mono font-semibold"
                    style={{ color: currentTheme.text }}
                  >
                    {coord.label === "H" ? coord.value.toFixed(2) : coord.value.toFixed(3)}
                  </motion.span>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.div>

      <motion.div
        className="absolute -top-2 -right-2 w-32 h-32 rounded-full opacity-20 blur-3xl pointer-events-none"
        style={{ backgroundColor: currentTheme.primary }}
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.15, 0.25, 0.15],
        }}
        transition={{
          duration: 4,
          repeat: Number.POSITIVE_INFINITY,
          ease: "easeInOut",
        }}
      />
    </motion.div>
  )
}