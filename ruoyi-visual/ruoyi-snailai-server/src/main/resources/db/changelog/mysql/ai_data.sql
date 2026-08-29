--liquibase formatted sql

--changeset seewis:ai-mysql-data-baseline dbms:mysql splitStatements:true
-- ============================================================
-- 九、初始化数据
-- ============================================================

-- 默认管理员：admin / admin123
INSERT INTO sai_user VALUES (1, 2, NULL, 'admin', 'admin', '',  'pbkdf2$120000$c25haWwtYWktYWRtaW4tMQ==$kakglT/wYKOgv/77Ah1stie58d/JbY2nGgq5DwgUBw4=', NULL, NOW(), NOW());

-- 插入常见的AI提供商
INSERT INTO sai_model_provider (provider_name, provider_key, description, is_enabled)
VALUES ('OpenAI', 'openai', 'OpenAI官方模型 (GPT-4, GPT-3.5等)', 1),
       ('Claude', 'claude', 'Anthropic Claude模型', 1),
       ('Ollama', 'ollama', '本地开源模型 (Llama, Mistral等)', 1),
       ('Google Gemini', 'gemini', 'Google Gemini模型', 1),
       ('阿里云百炼', 'qwen', '阿里云百炼 OpenAI 兼容模型 (Qwen等)', 1),
       ('DeepSeek', 'deepseek', 'DeepSeek OpenAI 兼容模型', 1),
       ('智谱AI', 'zhipu', '智谱AI OpenAI 兼容模型 (GLM等)', 1);



INSERT INTO sai_app VALUES (1, '1', 'ruoyi-ai', '', 'SAI_566a6bfbc26e4998b4841cc927d50c5d', 'LEAST_LOAD', 1, NOW(), NOW());
