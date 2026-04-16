export function getCurrentUserId() {
  try {
    const raw = localStorage.getItem('currentUser')
    if (!raw) return undefined
    const user = JSON.parse(raw)
    return user?.id
  } catch (e) {
    return undefined
  }
}

export function requireCurrentUserId() {
  const id = getCurrentUserId()
  if (id == null) throw new Error('未登录，缺少currentUser')
  return id
}
