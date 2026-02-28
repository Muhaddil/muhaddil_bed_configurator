"use client"

import { useState, useEffect, useCallback } from "react"
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
  const [debugData, setDebugData] = useState(null)

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

        case "updateDebug":
          setDebugData(data.debugData)
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

  const handleCloseNotification = useCallback(() => {
    setNotification(null)
  }, [])

  return (
    <ThemeProvider>
      <LocaleProvider initialLocales={locales}>
        <div className="w-full h-full relative">
          <AnimatePresence>
            {hudVisible && <HUDPanel configType={configType} title={title} coords={coords} debugData={debugData} />}
          </AnimatePresence>

          <AnimatePresence>
            {notification && (
              <Notification
                key={notification.id}
                type={notification.type}
                title={notification.title}
                message={notification.message}
                onClose={handleCloseNotification}
              />
            )}
          </AnimatePresence>
        </div>
      </LocaleProvider>
    </ThemeProvider>
  )
}

export default App