CREATE NONCLUSTERED INDEX [NCI_WI_Observation_SubjectId] ON [dbo].[Observation] ([SubjectId]) INCLUDE ([GeographicLevel], [LocationId], [TimeIdentifier], [Year]) WITH (ONLINE = ON);