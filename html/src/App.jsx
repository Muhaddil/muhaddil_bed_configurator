"use client"

import { useState, useEffect } from "react"
import { AnimatePresence } from "framer-motion"
import HUDPanel from "./components/HUDPanel"
import Notification from "./components/Notification"
import ThemeProvider from "./context/ThemeContext"
import { LocaleProvider } from "./context/LocaleContext"

function App() {
  const [hudVisible, setHudVisible] = useState(false)
  const [configType, setConfigType] = useState("bed")
  const [title, setTitle] = useState("CONFIGURATOR")
  const [coords, setCoords] = useState({ x: 0, y: 0, z: 0, h: 0 })
  const [notification, setNotification] = useState(null)
  const [locales, setLocales] = useState({})

  useEffect(() => {
    const handleMessage = (event) => {
      const data = event.data

      switch (data.action) {
        case "showHUD":
          setHudVisible(true)
          setConfigType(data.type || "bed")
          setTitle(data.title || "CONFIGURATOR")
          if (data.locales) {
            setLocales({ ...data.locales })
          }
          break

        case "hideHUD":
          setHudVisible(false)
          break

        case "updateLocales":
          setLocales({ ...data.locales })
          break


        case "updateCoords":
          setCoords({
            x: data.x,
            y: data.y,
            z: data.z,
            h: data.h,
          })
          break

        case "showNotification":
          setNotification({
            type: data.type,
            title: data.title,
            message: data.message,
            id: Date.now(),
          })
          break
      }
    }

    window.addEventListener("message", handleMessage)
    return () => window.removeEventListener("message", handleMessage)
  }, [])

  return (
    <ThemeProvider>
      <LocaleProvider initialLocales={locales}>
        <div className="w-full h-full relative">
          <AnimatePresence>
            {hudVisible && <HUDPanel configType={configType} title={title} coords={coords} />}
          </AnimatePresence>

          <AnimatePresence>
            {notification && (
              <Notification
                key={notification.id}
                type={notification.type}
                title={notification.title}
                message={notification.message}
                onClose={() => setNotification(null)}
              />
            )}
          </AnimatePresence>
        </div>
      </LocaleProvider>
    </ThemeProvider>
  )
}

export default App