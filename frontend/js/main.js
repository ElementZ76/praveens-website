const skills = ["Java", "Python", "Selenium", "REST Assured", "SQL", "Git"];

const projects = [
  { name: "Enterprise Test Automation Framework", detail: "Selenium Grid, Cucumber, TestNG, POM, Maven, Allure, Log4j2" },
  { name: "Proactive Cloud Autoscaling (AIOps)",  detail: "Python, AWS (EC2, Lambda, S3, SageMaker), scikit-learn, Locust" },
  { name: "FuelTrack Webapp",                     detail: "React, FastAPI, SQLite, Python, REST APIs" },
  { name: "Prashanthi Delights",                  detail: "WooCommerce store, live in production" }
];

const skillsList = document.getElementById("skills-list");

for (let i = 0; i < skills.length; i++) {
  const li = document.createElement("li");
  li.textContent = skills[i];
  skillsList.appendChild(li);
}

const projectsList = document.getElementById("projects-list");
projects.forEach(function (project) {
  const li = document.createElement("li");
  li.innerHTML = `<strong>${project.name}</strong><br>${project.detail}`;
  projectsList.appendChild(li);
});

const toggleBtn = document.getElementById("toggle-btn");
const moreAbout = document.getElementById("more-about");

toggleBtn.addEventListener("click", function () {
  moreAbout.classList.toggle("hidden");

  if (moreAbout.classList.contains("hidden")) {
    toggleBtn.textContent = "Read more";
  } else {
    toggleBtn.textContent = "Show less";
  }
});

const sendBtn = document.getElementById("send-btn");
const status  = document.getElementById("form-status");

sendBtn.addEventListener("click", function () {
  const name    = document.getElementById("name").value.trim();
  const email   = document.getElementById("email").value.trim();
  const message = document.getElementById("message").value.trim();

  if (name === "" || email === "" || message === "") {
    status.textContent = "Fill in all three fields.";
    return;
  }

  if (!email.includes("@")) {
    status.textContent = "That email address is missing an @.";
    return;
  }

  status.textContent = "Thanks " + name + ". This demo form doesn't send anywhere yet.";
});

document.getElementById("year").textContent = new Date().getFullYear();
