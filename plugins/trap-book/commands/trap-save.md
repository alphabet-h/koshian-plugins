---
name: trap-save
description: Manually extract a pitfall or strategy from the current session. Invokes the trap-extractor subagent with the last few turns. Use after solving a non-trivial issue that you want recorded.
allowed-tools: Agent
disable-model-invocation: false
argument-hint: "[pitfall|strategy|auto]"
---

# /trap-save

Extract a lesson from the current session manually. Default category is `auto` (the subagent decides).

## Procedure

1. Summarize the last 2-4 turns of this session into a short transcript excerpt (user message + assistant response that completed the task).
2. Invoke the trap-extractor subagent:

   ```
   Agent(
     subagent_type="trap-extractor",
     model="haiku",
     prompt="""Category hint: ${1:-auto}

<transcript-excerpt>
<paste the excerpt you assembled in step 1>
</transcript-excerpt>"""
   )
   ```

3. Report the subagent's 1-line result (`wrote: ...`, `merged: ...`, or `skip: ...`) back to the user.

## When to skip invoking

- If the session only answered a question (no failure→resolution pattern), tell the user "nothing to save" and do NOT invoke the subagent.
- If the user explicitly wrote `[PRIVATE]` in the session, tell them the excerpt is marked private and skip.
