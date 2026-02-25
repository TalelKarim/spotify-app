import axiosClient from "./axiosClient"

// 🔹 Get single track
export const getTrack = async (trackId) => {
  const response = await axiosClient.get(`/tracks/${trackId}`)
  return response.data
}

// 🔹 Search tracks
export const searchTracks = async (query) => {
  const response = await axiosClient.get(`/search?q=${query}`)
  return response.data
}

// 🔹 Play track
export const playTrack = async (trackId) => {
  const response = await axiosClient.post(`/tracks/${trackId}/play`)
  return response.data
}

// 🔹 Get analytics
export const getAnalytics = async () => {
  const response = await axiosClient.get(`/analytics`)
  return response.data
}

// 🔹 Create track
export const createTrack = async (trackData) => {
  const response = await axiosClient.post("/tracks", trackData)
  return response.data
}