# 1. DeepSeek R1 (32B) - The "Reasoning" Model
# Use this for complex logic, coding, and math.
# Status: Fits (~19GB VRAM). 
docker exec -it tradingagents-ollama ollama pull deepseek-r1:32b

# 2. Qwen 3 (32B) - The "Generalist" Model
# The latest from Alibaba (Nov 2025 era). Great for general chat and tools.
# Status: Fits (~19GB VRAM).
docker exec -it tradingagents-ollama ollama pull qwen3:32b

# 3. GPT-OSS (20B) - The "Standard" Model
# OpenAI's open weights. Good for standard compliance/formatting tasks.
# Status: Fits (~12GB VRAM).
docker exec -it tradingagents-ollama ollama pull gpt-oss:20b
