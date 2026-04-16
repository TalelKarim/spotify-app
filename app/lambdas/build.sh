#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
LAYERS_DIR="$ROOT_DIR/layers"

mkdir -p "$DIST_DIR"

log() {
  echo "▶ $1"
}

package_shared_logger_layer() {
  local layer_src="$LAYERS_DIR/shared"
  local zip_path="$LAYERS_DIR/shared-python.zip"

  if [ ! -d "$layer_src" ]; then
    echo "❌ Shared layer path not found: $layer_src"
    exit 1
  fi

  log "Packaging shared logger layer"
  rm -f "$zip_path"

  (
    cd "$layer_src"
    zip -qr "$zip_path" .
  )

  log "Created $zip_path"
}

zip_lambda() {
  local lambda_name="$1"
  local lambda_path="$2"
  local zip_path="$DIST_DIR/${lambda_name}.zip"

  if [ ! -d "$lambda_path" ]; then
    echo "❌ Lambda path not found: $lambda_path"
    exit 1
  fi

  log "Packaging ${lambda_name}"
  rm -f "$zip_path"

  (
    cd "$lambda_path"
    zip -qr "$zip_path" .
  )

  log "Created $zip_path"
}

LAMBDAS="
api_get_track:api/get_track
api_get_tracks:api/get_tracks

api_get_track_stats:api/get_track_stats
api_healthcheck:api/healthcheck

api_get_myhistory:api/get_myhistory

api_create_track:api/create_track
api_get_me:api/get_me
api_get_me_recently_played:api/get_me_recently_played

api_get_analytics:api/get_analytics
api_get_user:api/get_user
api_start_stream:api/start_stream
api_post_listening_event:api/post_listening_event
api_search:api/search




event_store_listening_event:events/store_listening_event
event_update_track_stats:events/update_track_stats
event_publish_notifications:events/publish_notifications
event_process_track_upload:events/process_track_upload/
orch_update_track_stats:orchestration/update_track_stats
orch_update_user_stats:orchestration/update_user_stats
orch_compute_analytics:orchestration/compute_analytics

tech_ingest_audio_metadata:tech/ingest_audio_metadata
tech_reindex_opensearch:tech/reindex_opensearch
tech_show_index_opensearch:tech/show_index_opensearch
"

# ---------------------------------
# Single lambda
# ---------------------------------
if [ $# -eq 1 ]; then
  TARGET="$1"

  package_shared_logger_layer

  while IFS=: read -r name path; do
    [ -z "$name" ] && continue

    if [ "$name" = "$TARGET" ]; then
      zip_lambda "$name" "$path"
      log "Done ✅"
      exit 0
    fi
  done <<< "$LAMBDAS"

  echo "❌ Unknown lambda: $TARGET"
  echo "Available lambdas:"
  echo "$LAMBDAS" | cut -d: -f1 | sed '/^$/d'
  exit 1
fi

# ---------------------------------
# All lambdas
# ---------------------------------
log "Packaging ALL lambdas"

package_shared_logger_layer

while IFS=: read -r name path; do
  [ -z "$name" ] && continue
  zip_lambda "$name" "$path"
done <<< "$LAMBDAS"

log "Done ✅"