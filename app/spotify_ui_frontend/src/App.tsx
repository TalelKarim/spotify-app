import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { AppShell } from './components/AppShell';
import HomePage from './pages/HomePage';
import SearchPage from './pages/SearchPage';
import TrackPage from './pages/TrackPage';
import UploadPage from './pages/UploadPage';
import ProfilePage from './pages/ProfilePage';
import AuthCallbackPage from './pages/AuthCallbackPage';
import { ProtectedRoute } from './components/ProtectedRoute';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/auth/callback" element={<AuthCallbackPage />} />
        <Route path="/" element={<AppShell />}>
          <Route index element={<HomePage />} />
          <Route path="search" element={<SearchPage />} />
          <Route path="tracks/:trackId" element={<TrackPage />} />
          <Route path="me" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
          <Route path="upload" element={<ProtectedRoute adminOnly><UploadPage /></ProtectedRoute>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
