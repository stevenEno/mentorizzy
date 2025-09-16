require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "index" do
    get collection_webhooks_path(collections(:writebook))
    assert_response :success
  end

  test "show" do
    webhook = webhooks(:active)
    get collection_webhook_path(webhook.collection, webhook)
    assert_response :success
  end

  test "new" do
    get new_collection_webhook_path(collections(:writebook))
    assert_response :success
    assert_select "form"
  end

  test "create with valid params" do
    collection = collections(:writebook)

    assert_difference "Webhook.count", 1 do
      post collection_webhooks_path(collection), params: {
        webhook: {
          name: "Test Webhook",
          url: "https://example.com/webhook",
          subscribed_actions: [ "", "card_published", "card_closed" ]
        }
      }
    end

    webhook = Webhook.order(id: :desc).first

    assert_redirected_to collection_webhook_path(webhook.collection, webhook)
    assert_equal collection, webhook.collection
    assert_equal "Test Webhook", webhook.name
    assert_equal "https://example.com/webhook", webhook.url
    assert_equal [ "card_published", "card_closed" ], webhook.subscribed_actions
  end

  test "create with invalid params" do
    collection = collections(:writebook)
    assert_no_difference "Webhook.count" do
      post collection_webhooks_path(collection), params: {
        webhook: {
          name: "",
          url: "invalid-url"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "edit" do
    webhook = webhooks(:active)
    get edit_collection_webhook_path(webhook.collection, webhook)
    assert_response :success
    assert_select "form"
  end

  test "update with valid params" do
    webhook = webhooks(:active)
    patch collection_webhook_path(webhook.collection, webhook), params: {
      webhook: {
        name: "Updated Webhook",
        subscribed_actions: [ "card_published" ]
      }
    }

    webhook.reload

    assert_redirected_to collection_webhook_path(webhook.collection, webhook)
    assert_equal "Updated Webhook", webhook.name
    assert_equal [ "card_published" ], webhook.subscribed_actions
  end

  test "update with invalid params" do
    webhook = webhooks(:active)
    patch collection_webhook_path(webhook.collection, webhook), params: {
      webhook: {
        name: ""
      }
    }

    assert_response :unprocessable_entity

    assert_no_changes -> { webhook.reload.url } do
      patch collection_webhook_path(webhook.collection, webhook), params: {
        webhook: {
          name: "Updated Webhook",
          url: "https://different.com/webhook"
        }
      }
    end

    assert_redirected_to collection_webhook_path(webhook.collection, webhook)
  end

  test "destroy" do
    webhook = webhooks(:active)

    assert_difference "Webhook.count", -1 do
      delete collection_webhook_path(webhook.collection, webhook)
    end

    assert_redirected_to collection_webhooks_path(webhook.collection)
  end
end
