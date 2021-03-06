require 'rails_helper'

RSpec.describe "Lessons", type: :request do
  it "creates a lesson and its associated assets, and renders JSON containing the new lesson's id" do
    teacher = User.create(
                      role: :teacher,
                      first_name: "FirstName1",
                      last_name: "LastName1",
                      email: "teacher@example.com",
                      password: "85kseOlqqp!v1@a7",
                      password_confirmation: "85kseOlqqp!v1@a7"
                      )

    teacher_token = SpecHelper.generate_token(teacher)

    lesson_title = "This is a title"
    lesson_text = "This is text."
    asset_storage_url= "http://www.example.com/assets/1"

    lesson_count_before = Lesson.all.count
    asset_count_before = Asset.all.count

    post "/api/v1/lessons", params: {lesson: {title: lesson_title, text: lesson_text, assets_attributes: [{storageURL: asset_storage_url}]}}, headers: { TOKEN: teacher_token }

    lesson_count_after = Lesson.all.count
    asset_count_after = Asset.all.count
    expect(lesson_count_after).to eq(lesson_count_before + 1)
    expect(asset_count_after).to eq(asset_count_before + 1)

    parsed_response = JSON.parse(response.body)

    expect(parsed_response).to have_key("lesson_id")
  end

  it "responds to a lesson show endpoint" do
    lesson = Lesson.create(title: "This is a title", text: "This is text.")
    storageURL = 'http://www.example.com/assets/1'
    asset = Asset.create(storageURL: storageURL, lesson_id: lesson.id)

    teacher = User.create(
                      role: :teacher,
                      first_name: "FirstName1",
                      last_name: "LastName1",
                      email: "teacher@example.com",
                      password: "85kseOlqqp!v1@a7",
                      password_confirmation: "85kseOlqqp!v1@a7"
                      )

    teacher_token = SpecHelper.generate_token(teacher)

    get "/api/v1/lessons/#{lesson.id}", headers: { TOKEN: teacher_token }

    response_lesson = JSON.parse(response.body)
    expect(response_lesson["id"]).to eq(lesson.id)
    expect(response_lesson["title"]).to eq(lesson.title)
    expect(response_lesson["text"]).to eq(lesson.text)
    expect(response_lesson["assets"][0]["storageURL"]).to eq(storageURL)
  end

  it "responds to a lessons index endpoint" do
    lesson_1 = Lesson.create(title: "This is a title", text: "This is text.")
    storageURL_1 = 'http://www.example.com/assets/1'
    asset_1 = Asset.create(storageURL: storageURL_1, lesson_id: lesson_1.id)

    lesson_2 = Lesson.create(title: "This is another title", text: "This is more text.")
    storageURL_2 = 'http://www.example.com/assets/2'
    asset_2 = Asset.create(storageURL: storageURL_2, lesson_id: lesson_2.id)

    teacher = User.create(
                      role: :teacher,
                      first_name: "FirstName1",
                      last_name: "LastName1",
                      email: "teacher@example.com",
                      password: "85kseOlqqp!v1@a7",
                      password_confirmation: "85kseOlqqp!v1@a7"
                      )

    teacher_token = SpecHelper.generate_token(teacher)

    get "/api/v1/lessons", headers: { TOKEN: teacher_token }

    parsed_response = JSON.parse(response.body)
    expect(parsed_response["lessons"].count).to eq(2)
    expect(parsed_response["lessons"][0]["title"]).to eq("This is a title")
    expect(parsed_response["lessons"][0]["id"]).to eq(lesson_1.id)
  end
end
