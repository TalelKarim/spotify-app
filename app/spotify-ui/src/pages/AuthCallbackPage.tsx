import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { exchangeCodeForTokens, parseUserFromIdToken } from '../auth/cognito';
import { saveUser } from '../auth/storage';
import { useAuth } from '../context/AuthContext';

export default function AuthCallbackPage() {
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const { setUserState } = useAuth();
  const [message, setMessage] = useState('Completing secure login...');

  useEffect(() => {
    const code = params.get('code');
    if (!code) {
      setMessage('Missing OAuth code.');
      return;
    }

    exchangeCodeForTokens(code)
      .then((tokens) => {
        const user = parseUserFromIdToken(tokens.idToken);
        saveUser(user);
        setUserState(user);
        navigate('/', { replace: true });
      })
      .catch((error) => setMessage(error instanceof Error ? error.message : 'Authentication failed'));
  }, [navigate, params, setUserState]);

  return (
    <div className="flex min-h-[50vh] items-center justify-center">
      <div className="rounded-3xl border border-spotify-border bg-black/30 px-8 py-10 text-center shadow-soft">
        <p className="text-lg font-semibold">{message}</p>
      </div>
    </div>
  );
}
