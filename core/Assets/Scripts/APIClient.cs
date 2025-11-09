using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Networking;

namespace Barbara.Core
{
    /// <summary>
    /// Cliente HTTP para comunicação com o backend API.
    /// </summary>
    public class APIClient : MonoBehaviour
    {
        [SerializeField]
        private string baseUrl =
#if UNITY_EDITOR
        "http://localhost:5000"  // Desenvolvimento
#else
        "https://barbara-api.azurewebsites.net"  // Produção
#endif
;

        private static APIClient _instance;
        public static APIClient Instance
        {
            get
            {
                if (_instance == null)
                {
                    var go = new GameObject("APIClient");
                    _instance = go.AddComponent<APIClient>();
                    DontDestroyOnLoad(go);
                }
                return _instance;
            }
        }

        /// <summary>
        /// GET /catalog
        /// </summary>
        public IEnumerator GetCatalog(Action<CatalogResponse> onSuccess, Action<string> onError)
        {
            string url = $"{baseUrl}/catalog?limit=50";
            using (UnityWebRequest request = UnityWebRequest.Get(url))
            {
                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    var response = JsonUtility.FromJson<CatalogResponse>(request.downloadHandler.text);
                    onSuccess?.Invoke(response);
                }
                else
                {
                    onError?.Invoke(request.error);
                }
            }
        }

        /// <summary>
        /// POST /avatar/generate
        /// </summary>
        public IEnumerator GenerateAvatar(string userId, string frontImageUrl, string sideImageUrl,
            Action<string> onSuccess, Action<string> onError)
        {
            string url = $"{baseUrl}/avatar/generate";
            var payload = new
            {
                userId,
                frontImageUrl,
                sideImageUrl
            };

            string json = JsonUtility.ToJson(payload);
            using (UnityWebRequest request = new UnityWebRequest(url, "POST"))
            {
                byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(json);
                request.uploadHandler = new UploadHandlerRaw(bodyRaw);
                request.downloadHandler = new DownloadHandlerBuffer();
                request.SetRequestHeader("Content-Type", "application/json");

                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    var response = JsonUtility.FromJson<AvatarGenerateResponse>(request.downloadHandler.text);
                    onSuccess?.Invoke(response.requestId);
                }
                else
                {
                    onError?.Invoke(request.error);
                }
            }
        }

        /// <summary>
        /// GET /avatar/:id
        /// </summary>
        public IEnumerator GetAvatarStatus(string avatarId, Action<AvatarStatusResponse> onSuccess, Action<string> onError)
        {
            string url = $"{baseUrl}/avatar/{avatarId}";
            using (UnityWebRequest request = UnityWebRequest.Get(url))
            {
                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    var response = JsonUtility.FromJson<AvatarStatusResponse>(request.downloadHandler.text);
                    onSuccess?.Invoke(response);
                }
                else
                {
                    onError?.Invoke(request.error);
                }
            }
        }

        [System.Serializable]
        private class AvatarGenerateResponse
        {
            public string requestId;
            public string status;
        }

        [System.Serializable]
        public class AvatarStatusResponse
        {
            public string id;
            public string userId;
            public string status;
            public string glbUrl;
            public string createdAt;
        }
    }
}
