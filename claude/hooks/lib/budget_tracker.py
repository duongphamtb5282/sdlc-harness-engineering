#!/usr/bin/env python3
"""Budget Tracker — stateful cost tracking for SDLC automation agents.

Tracks daily and per-session spending, enforces budget limits,
and provides a dashboard view of costs.

Usage:
    tracker = BudgetTracker("/path/to/project")
    tracker.record("architecture-review", "claude-opus", 15000, 2.50)
    status = tracker.check_limits(daily_limit=10.0, session_limit=2.0)
    print(tracker.dashboard())
"""

import json
import os
import time
from datetime import datetime


class BudgetTracker:
    """Stateful budget tracker that persists cost data to disk."""

    def __init__(self, project_dir="."):
        self.state_dir = os.path.join(
            project_dir, ".sdlc-automation-agent", ".orchestrator"
        )
        self.state_file = os.path.join(self.state_dir, "cost-state.json")
        os.makedirs(self.state_dir, exist_ok=True)
        self.state = self._load()

    def _load(self):
        if os.path.exists(self.state_file):
            try:
                return json.load(open(self.state_file))
            except (json.JSONDecodeError, OSError):
                pass
        return {
            "daily": {"spent": 0.0, "date": ""},
            "sessions": [],
            "total_spent": 0.0,
            "created_at": datetime.utcnow().isoformat(),
        }

    def _save(self):
        with open(self.state_file, "w") as f:
            json.dump(self.state, f, indent=2)

    def record(self, task_type, model, tokens, cost):
        """Record a cost event.

        Args:
            task_type: Type of task (e.g., 'architecture-review')
            model: Model used (e.g., 'claude-opus')
            tokens: Number of tokens consumed
            cost: Cost in USD
        """
        today = datetime.utcnow().strftime("%Y-%m-%d")

        # Reset daily counter if new day
        if self.state["daily"]["date"] != today:
            self.state["daily"] = {"spent": 0.0, "date": today}

        self.state["daily"]["spent"] += cost
        self.state["total_spent"] += cost
        self.state["sessions"].append({
            "task": task_type,
            "model": model,
            "tokens": tokens,
            "cost": round(cost, 4),
            "timestamp": datetime.utcnow().isoformat(),
        })

        # Keep only last 200 sessions to prevent file bloat
        if len(self.state["sessions"]) > 200:
            self.state["sessions"] = self.state["sessions"][-200:]

        self._save()

    def check_limits(self, daily_limit=10.0, session_limit=2.0, hard_stop=50.0):
        """Check current spending against limits.

        Returns:
            dict with spending status and alert level
        """
        today = datetime.utcnow().strftime("%Y-%m-%d")
        if self.state["daily"]["date"] != today:
            self.state["daily"] = {"spent": 0.0, "date": today}

        daily = self.state["daily"]["spent"]
        # Session spending = last 50 session entries
        session = sum(s["cost"] for s in self.state["sessions"][-50:])
        total = self.state["total_spent"]

        alerts = []
        if daily >= hard_stop:
            alerts.append("HARD_STOP")
        elif daily >= daily_limit:
            alerts.append("DAILY_LIMIT_REACHED")
        elif daily >= daily_limit * 0.8:
            alerts.append("DAILY_LIMIT_WARNING")

        if session >= session_limit:
            alerts.append("SESSION_LIMIT_REACHED")

        return {
            "daily_spent": round(daily, 2),
            "daily_limit": daily_limit,
            "daily_remaining": round(max(0, daily_limit - daily), 2),
            "daily_pct": round(min(100, (daily / daily_limit) * 100), 1) if daily_limit else 0,
            "session_spent": round(session, 2),
            "session_limit": session_limit,
            "session_remaining": round(max(0, session_limit - session), 2),
            "total_spent": round(total, 2),
            "hard_stop": hard_stop,
            "alerts": alerts,
        }

    def dashboard(self):
        """Return a formatted dashboard string."""
        status = self.check_limits()

        lines = []
        lines.append("━━━ Cost Dashboard ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        lines.append("")

        # Daily bar
        daily_bar = self._bar(status["daily_pct"])
        lines.append(
            f"  Today:    ${status['daily_spent']:.2f} / ${status['daily_limit']:.2f}  "
            f"{daily_bar}  {status['daily_pct']:.0f}%"
        )

        # Session bar
        session_pct = min(100, (status["session_spent"] / status["session_limit"]) * 100) if status["session_limit"] else 0
        session_bar = self._bar(session_pct)
        lines.append(
            f"  Session:  ${status['session_spent']:.2f} / ${status['session_limit']:.2f}  "
            f"{session_bar}  {session_pct:.0f}%"
        )

        lines.append(
            f"  Remaining until hard stop: ${status['hard_stop'] - status['daily_spent']:.2f}"
        )
        lines.append("")

        # Alerts
        if status["alerts"]:
            for alert in status["alerts"]:
                lines.append(f"  ⚠ {alert}")
            lines.append("")

        # Top tasks
        task_costs = {}
        for s in self.state["sessions"][-50:]:
            task = s["task"]
            task_costs[task] = task_costs.get(task, 0) + s["cost"]
        top_tasks = sorted(task_costs.items(), key=lambda x: -x[1])[:3]

        if top_tasks:
            lines.append("  Top tasks by cost:")
            for task, cost in top_tasks:
                model = "—"
                for s in reversed(self.state["sessions"][-50:]):
                    if s["task"] == task:
                        model = s["model"]
                        break
                lines.append(f"    {task:<25} ${cost:.2f}  ({model})")
            lines.append("")

        lines.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        return "\n".join(lines)

    @staticmethod
    def _bar(pct, width=10):
        filled = int(pct / 100 * width)
        empty = width - filled
        return "█" * filled + "░" * empty
