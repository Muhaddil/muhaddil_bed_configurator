import { createContext, useContext, useState, useEffect } from "react"

const LocaleContext = createContext()

const defaultLocales = {
  label_coordinates: "COORDINATES",
  label_controls: "CONTROLS",
  label_camera: "CAMERA",
  label_wheel_arrows: "WHEEL / ← →",
  label_up_down: "↑ ↓",
  label_enter: "ENTER",
  label_esc: "ESC",
  control_camera_desc: "Follow position",
  control_rotate_desc: "Rotate object",
  control_height_desc: "Adjust height",
  control_save_desc: "Save configuration",
  control_cancel_desc: "Cancel",
}

export function LocaleProvider({ children, initialLocales = {} }) {
  const [locales, setLocales] = useState({ ...defaultLocales, ...initialLocales })

  useEffect(() => {
    if (initialLocales && Object.keys(initialLocales).length > 0) {
      setLocales(prev => ({ ...prev, ...initialLocales }))
    }
  }, [JSON.stringify(initialLocales)])

  const updateLocales = (newLocales) => {
    setLocales(prev => ({ ...prev, ...newLocales }))
  }

  const t = (key) => locales[key] || key

  return (
    <LocaleContext.Provider value={{ locales, updateLocales, t }}>
      {children}
    </LocaleContext.Provider>
  )
}

export function useLocale() {
  const context = useContext(LocaleContext)
  if (!context) {
    throw new Error("useLocale must be used within a LocaleProvider")
  }
  return context
}