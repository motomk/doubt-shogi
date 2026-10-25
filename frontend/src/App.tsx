import { useEffect, useState } from 'react'

type ApiState = 'checking' | 'ok' | 'down'

export default function App() {
  const [api, setApi] = useState<ApiState>('checking')

  useEffect(() => {
    fetch('/api/health')
      .then((response) => setApi(response.ok ? 'ok' : 'down'))
      .catch(() => setApi('down'))
  }, [])

  return (
    <main>
      <h1>ダウト将棋</h1>
      <p>準備中です。</p>
      <p className="status">API: {api === 'checking' ? '確認中…' : api === 'ok' ? '接続できました' : 'つながりません'}</p>
    </main>
  )
}
