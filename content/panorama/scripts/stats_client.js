function CreateSkillBuild(title, description) {
  GameEvents.SendCustomGameEventToServer('stats_client_create_skill_build', {
    title: title,
    description: description,
  });
}
